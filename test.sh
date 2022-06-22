#!/bin/bash


#AUTH="Authorization: token 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"
GH_DEERE_API="https://github.deere.com/api/v3"
GH_REPO="$GH_DEERE_API/repos/repo_full_name"

if curl -o /dev/null -f -sH "$AUTH" $GH_REPO; then
echo "Error: Invalid repo, token or network issue!";  exit 1;
else
echo "Error: Invalid repo, token or network !";  exit 1;
fi



#curl -o /dev/null -f -sH 'Authorization: token my_access_token' https://api.github.com/user/repos || { echo "Error: Invalid repo, token or network issue!";  exit 1; }



file="/root/.coverlet/**/coverage.xml"


FILE=/etc/resolv.conf
if test -f "$FILE"; then
    echo "$FILE exists."
fi

FILE=version.json
if [ -f "$FILE" ]; then
    echo "$FILE exists."
fi

if [ -f "$file" ];
then
    echo "EXIT"
    echo "......................."
    exit 1
fi

echo "......................."



now=$(date +"%Y%m%d_%H%M%S")

echo "$now"





# Define variables.

#FILE="cov.zip"
#name="coverage.zip"

AUTH="Authorization: token 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"
#GH_DEERE_API="https://github.deere.com/api/v3"
#GH_REPO="$GH_DEERE_API/repos/$repo_full_name"


# Read asset tags.
response=$(curl -sH "$AUTH" https://github.deere.com/api/v3/repos/MPS/NETFrameworkInstallation/releases)

echo "$response"
# Get ID of the asset based on given name.
eval $(echo "$response" | grep -C3 "name.:.\+$name" | grep -w id | tr : = | tr -cd '[[:alnum:]]=')
[ "$id" ] || { echo "Error: Failed to get asset id, response: $response" | awk 'length($0)<100' >&2; exit 0; }

#curl -sL -H "$AUTH" -H'Accept: application/octet-stream' https://github.deere.com/api/v3/repos/$repo_full_name/releases/assets/$id > $FILE

echo "test"

#ids=$(echo $id | tr "id=" "\n")

#mkdir coverage
#mkdir coverage_old

#for id_temp in $ids
#do
#  curl -sL -H "$AUTH" -H'Accept: application/octet-stream' https://github.deere.com/api/v3/repos/MPS/NETStandard-lib/releases/assets/$id > "coverage/coverage$id_temp.zip"
#  unzip -o "coverage/coverage$id_temp.zip" -d"./coverage_old/coverage$id_temp"
#done

#for z in coverage/*.zip;
#do 
#  unzip -o "$z" -d"./coverage_old/"
#done


#- unzip -o coverage_old.zip -d "coverage_old/*"

#curl -sH "$AUTH" https://github.deere.com/api/v3/repos/MPS/NETStandard-lib/releases