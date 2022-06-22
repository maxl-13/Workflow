#!/bin/sh

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
echo -e "\n---------------------------------------------------------------------"
echo "Successfully created $outputdir/coverage.zip"
echo -e "---------------------------------------------------------------------\n"


#https://github.com/danielpalme/ReportGenerator
