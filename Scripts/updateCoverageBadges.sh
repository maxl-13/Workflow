#!/bin/sh

user=$1
token=$2

cd ~

git clone https://github.deere.com/MPS/NETStandard-lib.wiki.git
cd NETStandard-lib.wiki

git config --global user.name $user
git config --global user.email $token

git remote -v

rm -r badges
mkdir badges

cp /root/.assets/badges/badge_linecoverage.svg badges/badge_linecoverage.svg
cp /root/.assets/badges/badge_branchcoverage.svg badges/badge_branchcoverage.svg

git add badges/
git commit -m "Update Coverage Badges"
git push