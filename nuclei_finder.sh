#!/bin/bash


if [[ "$1" == "-h" ]]
then
        echo "Usage: /usr/bin/nuclei_finder  httpx_urls  new_dir_where_you_want_to_save_data"
        exit 0
fi

httpx_urls=$1
new_dir=$2

mkdir $new_dir &>/dev/null
nuclei -ut &>/dev/null
nuclei -l $httpx_urls -nc -silent > nuclei_finding1

# Important findding 

cat nuclei_finding1 | awk '{print $3,$5,$6}' | grep -E "critcal|high|medium" | sed '/info/d' > $new_dir/Important_find

# Extract the all finding type

cat nuclei_finding1 | awk '{print $3}' | sort -u | tr -d "[]" > file_type

# Saving the all type in files

while read type
do
        new_file=$type.txt
        cat nuclei_finding1 | fgrep $type | sort -u > $new_dir/$new_file

done < file_type

rm file_type
