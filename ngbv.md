<h1>Test Project for Nerdbank.GitVersioning (Semantic Versioning)</h1>
https://github.com/dotnet/Nerdbank.GitVersioning


<h2>Installation</h2>

Install nbgv in the root folder
```ps1
dotnet tool install --tool-path . nbgv
nbgv install
```
Use it with ```./nbgv```
This will create your initial `version.json` file.
It will also add/modify your `Directory.Build.props` file in the root of your repo to add the `PackageReference` to the latest `Nerdbank.GitVersioning` package available on nuget.org.

<h3>Our version.json example</h3>

```json
{
  "$schema": "https://raw.githubusercontent.com/dotnet/Nerdbank.GitVersioning/master/src/NerdBank.GitVersioning/version.schema.json",
  "version": "1.2.7-dev.{height}",
  "publicReleaseRefSpec": [
    "^refs/heads/v\\d+\\.\\d+\\.\\d+$",
    "^refs/heads/mainn$"
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
<h3>File Format of version.json file </h3>
https://github.com/dotnet/Nerdbank.GitVersioning/blob/master/doc/versionJson.md

<h3>Settings</h3>

```
version: 1.2.7-dev.{height}

<Major>.<Minor>.<Build>-dev.<patch>
```
height = Git 'height' is the number of commits in the longest path from HEAD


The ```publicReleaseRefSpec``` field causes builds out of certain branches or tags to automatically drop the -gabc123 git commit ID suffix from the version.


The ```release``` settings are nessesary for a new release. <br>
You can create a new release branch with the command:

```
nbgv prepare-release
```
The branch will be named "release-{version}" and build number will be increased.  
The version number is cut from '-dev'


<h2>My Opinion </h2>
Easy to install and easy to use, but if u want to understand the tool u have to read the syntax of the tool.