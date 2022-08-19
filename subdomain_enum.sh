#!/bin/bash

#This script takes benefit of four tool assetfinder,subfinder,sublist3r,amass
#Usage==./subdomain_enum.sh root_domains output_subdomain
if [ "$1" == "-h" ];
then
        echo "Usage: subdomain_enum.sh root_domains output_sub_domains"
        exit 0
fi

domains=$1
output=$2

cat $domains | assetfinder > new_file1

subfinder -dL $domains -silent -recursive > new_file2

amass enum -df $domains > new_file3

while read line
do
        sublist3r -d $line 2> /dev/null | grep "$line" | sed '1d'  >> new_file4
done < $domains

cat new_file1 > new_file
cat new_file2 >> new_file
cat new_file3 >> new_file
cat new_file4 >> new_file

rm new_file1 new_file2 new_file3 new_file4

cat new_file | uniq -u > $output

echo "Enumeration is complete"
