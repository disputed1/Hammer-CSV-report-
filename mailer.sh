#!/bin/bash
#### Variables ####
#email="email"
report=/path/satellite_hosts_$(date +%Y%m%d)*
lreport=/path/satellite_hosts_$(date +%Y%m%d)*
####  Puller ####
if [ ! -f $lreport ];
  then
    scp -P 1234 hostname:$report /report_location/
  else
    :
fi
### Email the reports
echo "This report is automatically generated each day" | mutt -x -s "Production Satellite Daily Report -- $(date +%Y%m%d)" $email -a $lreport
### Clean up old reports (remove older than 30 days)
find /reportlocation/ -type f -mtime +1 -exec rm {} \; 
