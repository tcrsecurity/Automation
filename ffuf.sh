#!/bin/bash

rm -r $1.new &>/dev/null
rm ffuf_file &>/dev/null
MailID=automation2354@gmail.com

/bin/mkdir $1.new

while read line
do

    /root/go/bin/ffuf -w /root/content_discovery_all.txt -t 300 -u $line 2>/dev/null | awk '{print $1}' >> ffuf_file
    sed -i '1i  ==================================================================' ffuf_file
    new=$(echo "$line" | awk -F "/" '{print $3}')
    /bin/mv ffuf_file  $new
    /bin/mv $new $1.new
    echo "Endpoins of $new is complete" | mail -s "$new Endpoints" $MailID

done < $1
