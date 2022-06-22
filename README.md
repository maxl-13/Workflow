[![Build Status](https://drone.deere.com/api/badges/MPS/NETStandard-lib/status.svg)](https://drone.deere.com/MPS/NETStandard-lib)
![Branch badge](https://github.deere.com/MPS/NETStandard-lib/wiki/badges/badge_branchcoverage.svg)
![Line badge](https://github.deere.com/MPS/NETStandard-lib/wiki/badges/badge_linecoverage.svg)

<h1 align="center">Creating a CI/CD Pipeline</h1>
<p>This example project explains how to automate a CI/CD Workflow in Drone. The dotnet tool <a align="left" href="https://github.com/dotnet/Nerdbank.GitVersioning" target="_blank">Nerdbank.Gitversioning</a> is used for Semantic Versioning. <b>The Goal of the Pipeline is to automate Builds and Tests, publish Packages on GitHub and create Releases in GitHub</b></p>


<h2>Workflow</h2>

<p>You can see our Workflow in the image below</p>
<ol>
  <li>Developing Code</li>
  <li>Pushing Code to our GitHub Repository (each Branch)</li>
  <ul>
    <li>Build Debug</li>
    <li>Unit tests</li>
  </ul>
  <li>Pushing Code to our GitHub Repository (each Main and Release-* Branch)</li>
  <ul>
    <li>Build Release</li>
    <li>Unit tests</li>
  </ul>
  <li>Promotion in Drone (Main Branch)
  <ul>
    <li>Creates new Release Branch</li>
    <li>Bump Version</li>
  </ul>
  <li>Promotion in Drone (Release-* Branch)</li>
  <ul>
    <li>Nuget Push to GitHub</li>
    <li>GitHub Release</li>
      <ul>
        <li>Assets: Code Coverage File, DLLs</li>
        <li>Add your own Release Notes</li>
        <li>and Automate Release Notes</li>
    </ul>
  </ul>
</ol>
<br>
<p>
   <a align="left" target="_blank">
   <img width="100%" src="https://github.deere.com/MPS/NETStandard-lib/blob/main/images/workflow.png"></a>
</p>
<br>

<h1 align="center">Add the CI/CD Workflow to your Project</h1>

<h2>Add CI/CD Pipeline</h2>

<details>
<summary>.drone.yml</summary>
<br>
<p>Adjust the Pipeline for your Project</p>
<ul>
  <li>Set the $PROJECT_PATH of your Solution File in all Steps called "prepare variables"</li>
  <li>Add BOT_USERNAME and GITHUB_PACKAGES_TOKEN in your Drone Secrets</li>
  <li>The Token requires a GitHub Personal Access Token with scope "write packages"</li>
  <li>Change the Filenames in the .NET Build Release Step (CD Pipeline) --> This Files will be added in your GH Release</li>
</ul>

</details>

<h2>Add Nerdbank.Gitversioning (nbgv) Tool</h2>

<h3>Add `Directory.Build.props` in your root Folder</h3>

```c#
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="Current" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup>
    <PackageReference Include="Nerdbank.GitVersioning" Condition="!Exists('packages.config')">
      <PrivateAssets>all</PrivateAssets>
      <Version>3.5.107</Version>
    </PackageReference>
  </ItemGroup>
</Project>
```

<h3>Add your Versionfile</h3>

<details>
<summary>version.json</summary>

`"version":` Set your Version here<br>
`"publicReleaseRefSpec":` included paths drop the `-gabc123` git commit ID from the Version<br>
`"release":` Settings for creating a new Release Branch with the command `nbgv prepare-release`<br>

```json
{
  "$schema": "https://raw.githubusercontent.com/dotnet/Nerdbank.GitVersioning/master/src/NerdBank.GitVersioning/version.schema.json",
  "version": "1.0.0-dev.{height}",
  "publicReleaseRefSpec": [
    "^refs/heads/version\\d+\\.\\d+\\.\\d+$",
    "^refs/heads/mainn$",
    "^refs/tags/v\\d+\\.\\d+\\.\\d+$"
  ],
  "cloudBuild": {
    "buildNumber": {
      "enabled": true
    }
  },
  
  "release": {
    "branchName": "release-{version}",
    "versionIncrement": "build",
    "firstUnstableTag": "dev"
  }
}
```

<p>The full <a align="left" href="https://github.com/dotnet/Nerdbank.GitVersioning/blob/main/doc/versionJson.md" target="_blank">File Format</a> you can find here.</details>

<h2>Add NuGet Package Information in every .csproj</h2>

<p>Each Project requires Package Information or needs the set disabled for packing<p>

```c#
  <PropertyGroup>
    <RepositoryUrl>https://github.deere.com/{ORG}/{REPO}</RepositoryUrl>
    <PackageId>[Package1]</PackageId>
    <PackageDescription>[PackageDescriptionProject1]</PackageDescription>
  </PropertyGroup>
```

```c#
  <PropertyGroup>
    <IsPackable>false</IsPackable>
  </PropertyGroup>
```

<h2>Add these Files in your Repository</h2>

<p>Open the Dropdown for details</p>

<h3>Shell Scripts</h3>

<p>This Scripts will be needed to run the Pipeline. Store then in your root Folder "Scripts/*"</p>

<details>
<summary>createReleaseBranch.sh</summary>
<br>
<p>This Script bump the version number (default patch) and creats a new Release-* Branch. For Minor and Major Releases add a variable "increment" on your Promote in Drone</p>

```shell
#!/bin/sh

# Usage: ./createReleaseBranch.sh $BOT_USERNAME $BOT_GITHUB_TOKEN $increment

# Define Variables GH User, GH Token, versionIncrement (Major/Minor)
user=$1
token=$2
versionIncrement=$3

# Install dotnet tool nbgv
export PATH="$PATH:/root/.dotnet/tools"
dotnet tool install -g nbgv

# GH Authentication
git config --global user.name $user
git config --global user.email $token

# Check for uncommitted Files
if [ \! -z "$(git status --porcelain)" ]; then 
    git add .
    git commit -m "Drone init"
fi

# Bump Version if Major or Minor Increment
if [ "$versionIncrement" == "Major" ] || [ "$versionIncrement" == "Minor" ]
then
nbgv prepare-release --versionIncrement $versionIncrement
fi

# Get Release Branch name (Version Main Branch)
release_branch_name="release-$(nbgv get-version --variable version)"

# Create new Release Branch
nbgv prepare-release

# Push Main and Release Branch to GH
git push --set-upstream origin main
git checkout $release_branch_name
git push --set-upstream origin $release_branch_name
```
</details>


<details>
<summary>getCoverageHistory.sh</summary>
<br>
<p>This File downloads the Coverage History from the latest Release and copy the files in "historydir" for the next Script.</p> 


```shell
#!/bin/sh

# Usage: ./getCoverageHistory.sh $API_KEY

# Downloading Coverage History from latest GitHub Release

# Define Variables
token=$1
asset_filename="coverage.zip" # Search for this asset

repo_full_name=$(git config --get remote.origin.url | sed 's/.*:\/\/github.deere.com\///;s/.git$//')

AUTH="Authorization: token $token"

# Get Latest Release Information
response=$(curl -sH "$AUTH" https://github.deere.com/api/v3/repos/$repo_full_name/releases/latest)

# Get ID of the asset based on given name or Exit if no ID is found.
eval $(echo "$response" | grep -C3 "name.:.\+$asset_filename" | grep -w id | tr : = | tr -cd '[[:alnum:]]=')
[ "$id" ] || { echo "Error: Failed to get asset id, response: $response" | awk 'length($0)<100' >&2; exit 0; }

# Create Output Folders
mkdir coverage
mkdir historydir

# Download Asset File
echo -e "\n---------------------------------------------------------------------"
echo "Downloading $asset_filename from assetId $id"
curl -sL -H "$AUTH" -H'Accept: application/octet-stream' https://github.deere.com/api/v3/repos/$repo_full_name/releases/assets/$id > "./coverage$id.zip"
unzip -q -j -o "./coverage$id.zip" -d "./coverage"
echo "Done."
echo -e "---------------------------------------------------------------------\n"

# Copy Coverage History to the target folder to create the Coverage Report
cp coverage/*CoverageHistory.xml historydir/
```
</details>


<details>
<summary>generateCodeCoverage.sh</summary>

<p>This File creates the Code Coverage Asset for the GH Release and generates new Badges for the Readme File.</p> 

```shell
#!/bin/sh

# Usage: ./getCoverageHistory.sh "$COVERAGE_RESULTS/**/coverage.cobertura.xml" "$ASSET_PATH" "historydir/"

# Code Coverage File .xml
file=$1
# Store Assets for GH Release
outputdir=$2
# Code Coverage History
historydir=$3

# Get Repo Name and Version 
repo_full_name=$(git config --get remote.origin.url | sed 's/.*:\/\/github.deere.com\///;s/.git$//')
version=$(sed 's/.*"version": "\(.*\)".*/\1/;t;d' version.json)


#Check if Coverage File exits
if [ ! -f $file ];
then
    echo -e "\n---------------------------------------------------------------------"
    echo "No Coverage File found!"
    echo -e "---------------------------------------------------------------------\n"
    exit 0
fi

# Else create a Coverage Report
export PATH="$PATH:/root/.dotnet/tools"
dotnet tool install -g dotnet-reportgenerator-globaltool
reportgenerator -reports:"$file" -targetdir:"$outputdir/reports" -reporttypes:"Html;HtmlSummary;HtmlChart;XML;XMLSummary" -historydir:"$historydir" -title:"$repo_full_name" -tag:"$version"
reportgenerator -reports:"$file" -targetdir:"$outputdir/badges" -reporttypes:"Badges" -verbosity:Warning
echo -e "\n---------------------------------------------------------------------"
echo "Code Coverage Files are created!"
echo -e "---------------------------------------------------------------------\n"

# Zip Coverage files for Release
mkdir -p $outputdir/reports/cov_history && cp ./historydir/* $outputdir/reports/cov_history
cd $outputdir/reports
zip -q -r $outputdir/coverage.zip .
```
</details>

<details>
<summary>ghApiRelease.sh</summary>
<br>
<p>This Script create the GitHub Release, auto generate Release Notes and upload Release Assets.</p>

```shell
#!/bin/sh

# Usage: ./ghApiRelease.sh $API_KEY $path_to_assets

# Get GH PAT Token
token=$1
asset_path=$2

# Get version from version.json
version=$(sed 's/.*"version": "\(.*\)".*/\1/;t;d' version.json)

# Get Branch Name
branch=$(git rev-parse --abbrev-ref HEAD)

# Get Organisation/Repo
repo_full_name=$(git config --get remote.origin.url | sed 's/.*:\/\/github.deere.com\///;s/.git$//')

# Convert Release Notes File
sed ':a;N;$!ba;s/\n/\\n/g' releaseNotes.md >> new_releaseNotes.md
body="$(cat new_releaseNotes.md)"

# Generate Post Data
generate_post_data()
{
  cat <<EOF
{
  "tag_name": "$version",
  "target_commitish": "$branch",
  "name": "$version",
  "body": "$body",
  "draft": false,
  "prerelease": false,
  "generate_release_notes": true
}
EOF
}

# Config Variables for GH API
AUTH="Authorization: token $token"
GH_DEERE_API="https://github.deere.com/api/v3"
GH_REPO="$GH_DEERE_API/repos/$repo_full_name"


# Check Connection
curl -o /dev/null -sH "$AUTH" $GH_REPO || { echo "Error: Invalid repo, token or network issue!";  exit 1; }

echo -e "\n---------------------------------------------------------------------"
echo "Creating Release for $repo_full_name"
echo "Version: $version"
echo -e "---------------------------------------------------------------------\n"

# Create GH Release
response=$(curl -X POST -H "$AUTH" -H "Accept: application/vnd.github.v3+json" --data "$(generate_post_data)" "https://github.deere.com/api/v3/repos/$repo_full_name/releases")

# Get Release ID for upload Assets
eval $(echo "$response" | grep -m 1 "id.:" | grep -w id | tr : = | tr -cd '[[:alnum:]]=')
[ "$id" ] || { echo "Error: Failed to get release id for tag: $tag"; echo "$response" | awk 'length($0)<100' >&2; exit 1; }

# Attach all files from asset_path to the GH Release
cd $asset_path
while read file
do
  echo "$file"
  if test -f "$file"; then
    curl -H "$AUTH" -H "Accept: application/vnd.github.v3+json" -H "Content-Type: application/octet-stream" --data-binary @"$file" "https://github.deere.com/api/uploads/repos/$repo_full_name/releases/$id/assets?name=$(basename $file)"
  fi
done < <(ls)
```
</details>


<h3>Neccessary Files for Release Notes</h3>

<details>

<summary>releaseNotes.md</summary>
<br>
<p>Add your own Release Notes by creating a `releaseNotes.md` File. [Optional]</p>

</details>

<details>
<summary>.github/release.yml.</summary>
<br>
<p>You can Label your Pull Requests and Strukture them in this file. (for auto genenerating Release Notes)</p>

```yaml
changelog:
  exclude:
    labels:
      - ignore-for-release
    authors:
      - octocat
  categories:
    - title: Breaking Changes 🛠
      labels:
        - Semver-Major
        - breaking-change
    - title: New Features 🎉
      labels:
        - Semver-Minor
        - enhancement
    - title: Bugfixes
      labels:
        - bug
    - title: Other Changes
      labels:
        - "*"
```
</details>


<h2>Prepare a new Release</h2>

<h3>First Step - Choose new Version Number</h3>

<p>Your Application is ready for a new Release. Some Bugs are fixed and/or new functions are added. Push your main Branch and promote this build. Choose your version number. The default version bump is "patch". By adding the environment varibale "increment" with the value "Major" or "Minor" you overwrite the patch release.</p>
<p>The Version Number is defined as MAJOR.MINOR.PATCH<br>

MAJOR version when you make incompatible API changes,<br>
MINOR version when you add functionality in a backwards compatible manner, and<br>
PATCH version when you make backwards compatible bug fixes.</p>

<h3>Secound Step - Promote your Build in Drone from the Main Branch</h3>

<p>This will create a new branch called release-{version} e.g. release-4.2.7 and increase the version number. The new Release-Branch and the Main-Branch will be pushed in the repo.</p>

<details><summary>For Major and Minor Releases add an env Variable !! Important !! Click add</summary>
  <a align="left" target="_blank">
  <img width="400" src="https://github.deere.com/MPS/NETStandard-lib/blob/main/images/promote.png"></a>
</details>

<h3>Third Step - Last Changes</h3>

<p>If necessary pull the new Release-Branch and make a git checkout.
You can prepare some last Changes for the new Release. 
After that push the new branch. [Optional]</p>

<h3>Fourth Step - Create Release</h3>

<p>If the Build was successfull you can make a Promote in Drone from the Release-Branch.
This will create a Nuget Package and a Github Release.</p>


<h1 align="center">Important Pipelinesteps</h1>

<h2>Code Coverage</h2>

<p>Add Package References (coverlet.collector) in your !! TEST !! .csproj</p>

```c#
  <ItemGroup>
    <PackageReference Include="coverlet.collector" Version="3.1.0">
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
      <PrivateAssets>all</PrivateAssets>
    </PackageReference>
  </ItemGroup>
```

The Argument `--collect:"XPlat Code Coverage` on `dotnet test` creates a the Coverage Report.
The Drone Pipeline installs the Tool dotnet-reportgenerator and
converts the Report in a userfriendly Coverage File. For including Coverage History look the script `getCoverageHistory.sh` and `generateCodeCoverage.sh`

<details>
<summary>Example Coverage File</summary>
<br>
  <a align="left" target="_blank">
  <img width="100%" src="https://github.deere.com/MPS/NETStandard-lib/blob/main/images/Coverage.png"></a>
</details>

<h2>Task Create Nuget Package</h2>

<p>This commands will create your Package.</p>

```yaml
dotnet pack $PROJECT_PATH --configuration $CONFIGURATION --output $NUGET_PKG_PATH/

dotnet nuget push $NUGET_PKG_PATH/*.nupkg --source https://github.deere.com/_registry/nuget/MPS/index.json -k $API_KEY --skip-duplicate
```

<p>You only have to add your RepositoryUrl in your .csproj and choose your Package Name + Description.</p>

```c#
  <PropertyGroup>
    <RepositoryUrl>https://github.deere.com/{ORG}/{REPO}</RepositoryUrl>
    <PackageId>[PackageDescription]</PackageId>
    <PackageDescription>[PackageDescription]</PackageDescription>
  </PropertyGroup>
```

<h2>Task GitHub Release</h2>

The Script `ghApiRelease.sh` will create a GH Release with GitHub REST API.

```shell
./ghApiRelease.sh $API_KEY $path_to_assets
```

<p>The Script requires the Personal Access Token and the path to your asset files.</p>

<h3>Generate Release Notes</h3>

<p>There are two ways how you can add your Release Notes. Use both of them or choose your favorite</p>

<b>Automatically generate Release Notes</b>
<br><br>
For this task you need a config file in `.github/release.yml`
Now you can mark your pull_requests with labels and structure them in the config file. You can set "generate_release_notes": false in `ghApiRelease.sh`.
<details>
<summary>Example Release</summary>
<br>
  <a align="left" target="_blank">
  <img width="250" src="https://github.deere.com/MPS/NETStandard-lib/blob/main/images/GHRelease.png"></a>
  <a align="left" target="_blank">
  <img width="550" src="https://github.deere.com/MPS/NETStandard-lib/blob/main/images/Labels.png"></a>
</details>

<b>Add releaseNotes.md</b>

Add your own Release Notes by creating a `releaseNotes.md`.
