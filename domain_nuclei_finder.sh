#!/bin/bash


#Bash shell scripting for finding bugs quickly
# This script taking benefit of four tool assetfinder,subfinder,sublist3r and amass
# Firs this script find all subdomains of the root_domains
# Second this script find alive hosts from httpx tool
# Third this script try to find vulnerabily using nuclei 
# Fourth create file for every type of finding
# Usage: subdomain_enum.sh root_domains output_sub_domains output_httpx_url


if [[ ! $(id -u) -eq 0 ]]
then
        echo "You are not root user......"
        exit 1
fi


if [[ "$1" == "-h" ]]
then
        echo "Usage: domain_nuclei_finder root_domains output_sub_domains outpu_httpx_urls"
        exit 2
fi

if [[ ! -e /usr/bin/assetfinder ]]
then 
        echo " Installing assetfinder ......"
        go get -u github.com/tomnomnom/assetfinder
        cp /root/go/bin/assetfinder /usr/bin/assetfinder
fi

if [[ ! -e /usr/bin/subfinder ]]
then 
        echo " Installing subfinder ......"
        go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
        cp /root/go/bin/subfinder /usr/bin/subfinder
fi

if [[ ! -e /usr/bin/amass ]]
then 
        echo " Installing amass......"
        go install -v github.com/OWASP/Amass/v3/...@master
        cp /root/go/bin/amass /usr/bin/amass
fi

if [[ ! -e /usr/bin/nuclei ]]
then 
        echo " Installing nuclei ......"
        go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
        cp /root/go/bin/nuclei /usr/bin/nuclei
fi


domains=$1
subdomains=$2
httpx_urls=$3

cat $domains | /usr/bin/assetfinder > new_file1

/usr/bin/subfinder -dL $domains -silent -all > new_file2

amass enum -df $domains > new_file3

while read line
do
        /usr/bin/sublist3r -d $line 2> /dev/null | grep "$line" | sed '1d'  >> new_file4
done < $domains

cat new_file1 > new_file
cat new_file2 >> new_file
cat new_file3 >> new_file
cat new_file4 >> new_file

while read lin
do

        cat new_file | sort -u | sed '/\*/s/\*\.//' | grep -i $lin  >> $subdomains

done < $domains


/root/go/bin/httpx -l $subdomains -silent > $httpx_urls


mkdir Nuclei &>/dev/null
nuclei -ut &>/dev/null
nuclei -l $httpx_urls -nc -silent > nuclei_finding

# Important finding 

cat nuclei_finding | awk '{print $3,$5,$6}' | grep -E "critcal|high|medium" | sed '/info/d' > Nuclei/Important_find

# Extract the all finding type

cat nuclei_finding | awk '{print $3}' | sort -u | tr -d "[]" > finding_types

# Saving the all type in files

while read type
do
        new_file=$type.txt
        cat nuclei_finding | fgrep $type | sort -u > Nuclei/$new_file

done < finding_types

rm new_file new_file1 new_file2 new_file3 new_file4 finding_types
