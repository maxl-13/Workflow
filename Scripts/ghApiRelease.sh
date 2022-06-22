#!/bin/sh

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
echo -e "\n---------------------------------------------------------------------"
if curl -o /dev/null -f -sH "$AUTH" $GH_REPO; then
  echo "Creating Release for $repo_full_name"
  echo "Version: $version"
else
  echo "Error: Invalid repo, token or network issue!";
  exit 1;
fi
echo -e "---------------------------------------------------------------------\n"

# Create GH Release
response=$(curl -X POST -sH "$AUTH" -H "Accept: application/vnd.github.v3+json" --data "$(generate_post_data)" "https://github.deere.com/api/v3/repos/$repo_full_name/releases")

# Get Release ID for upload Assets
eval $(echo "$response" | grep -m 1 "id.:" | grep -w id | tr : = | tr -cd '[[:alnum:]]=')
[ "$id" ] || { echo "Error: Failed to get release id for tag: $tag"; echo "$response" | awk 'length($0)<100' >&2; exit 1; }

# Attach all files from asset_path to the GH Release
cd $asset_path
echo -e "\n---------------------------------------------------------------------"
echo "Start uploading Files from $asset_path:"
while read file
do
  echo "$file"
  if test -f "$file"; then
    curl -sH "$AUTH" -sH "Accept: application/vnd.github.v3+json" -sH "Content-Type: application/octet-stream" --data-binary @"$file" "https://github.deere.com/api/uploads/repos/$repo_full_name/releases/$id/assets?name=$(basename $file)"
    echo "$file uploaded"
  fi
done < <(ls)
echo -e "---------------------------------------------------------------------\n"


#https://gist.github.com/stefanbuck/ce788fee19ab6eb0b4447a85fc99f447
#https://www.youtube.com/watch?v=88FWrfHCIqo
