#!/bin/sh

# Downloading Coverage History from latest GitHub Release

# Define Variables
token=$1
asset_filename="coverage.zip"

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
curl -sL -sH "$AUTH" -H'Accept: application/octet-stream' https://github.deere.com/api/v3/repos/$repo_full_name/releases/assets/$id > "./coverage$id.zip"
unzip -q -j -o "./coverage$id.zip" -d "./coverage"
echo "Done."
echo -e "---------------------------------------------------------------------\n"


# Copy Coverage History to the target folder to create the Coverage Report
cp coverage/*CoverageHistory.xml historydir/
echo -e "\n---------------------------------------------------------------------"
echo "Founded History Coveragefiles: $(ls historydir/ | wc -l)" 
echo -e "---------------------------------------------------------------------\n"








