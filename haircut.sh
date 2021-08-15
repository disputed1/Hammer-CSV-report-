#!/bin/bash
##### Josh McNab #####
#!---- Variables  ----!#
timestamp=`date "+%Y%m%d"`
fullreport=/var/www/html/pub/dl/satreport
runoff=/var/tmp/sat_cleanup_tmp
cutoff=$(date -d '45 days ago' +%s)
#!---- Time Logic  ----!#
while IFS=, read -r col1 col2
  do
    if [ "$cutoff" -gt "$col2" ];
      then
#!---- Hammer Time  ----!#
#       echo $col1 "is about to deleted"
       hammer host delete --name $col1
else
        :
  fi
done < $runoff/parser_$timestamp.csv
