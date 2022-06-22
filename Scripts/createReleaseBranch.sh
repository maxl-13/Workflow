#!/bin/sh

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



#https://ml-software.ch/posts/versioning-made-easier-with-nerdbank-gitversioning