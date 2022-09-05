#!/bin/bash

#My first bash scripting for automation
# This tool taking benefit of four tool assetfinder,subfinder,sublist3r and amass
# Usage: subdomain_enum.sh root_domains output_sub_domains


if [ "$1" == "-h" ];
then
        echo "Usage: subdomain_enum.sh root_domains output_sub_domains"
        exit 0
fi


domains=$1
output=$2

cat $domains | /root/bin/assetfinder > new_file1

/root/bin/subfinder -dL $domains -silent -recursive > new_file2

amass enum -df $domains > new_file3

while read line
do
        /root/sublist3r -d $line 2> /dev/null | grep "$line" | sed '1d'  >> new_file4
done < $domains

cat new_file1 > new_file
cat new_file2 >> new_file
cat new_file3 >> new_file
cat new_file4 >> new_file


rm new_file1 new_file2 new_file3 new_file4

while read lin
do

        cat new_file | sort -u | sed '/\*/s/\*\.//' | grep -i $lin  >> $output

done < $domains



echo "Enumeration is complete"
