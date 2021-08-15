##### Josh McNab #####
##### The additional config parameters can be found in /etc/hammer/cli.modules.d/csv.yml
#!---- Script Variables ----!#
timestamp=`date "+%Y%m%d"`
fullreport=/var/www/html/pub/dl/satreport
runoff=/var/tmp/sat_cleanup_tmp
cutoff=$(date -d '45 days ago' +%s)
haircut=/usr/local/scripts/satreport/haircut.sh
#!---- Log pruner ----!#
find $fullreport -type f -name '*.csv' -mtime +30 | xargs rm -f { } \;
find $runoff -type f -name '*.csv' -mmin +59 | xargs rm -f { } \;
#!---- hammer csv reporting ----!#
hammer csv content-hosts \
--export \
--itemized-subscriptions \
--verbose \
--columns "Server Name,IP,Organization,Environment,Virtual,Guest of Host,Host collections,Content View,Products,Subscription Status,Subscription Name,Service Level,Katello Agent,OS,Arch,Sockets,Cores,RAM,Errata
Security,Errata Bugfix,Errata Enhancement,Errata Total,Registered at,Registered through,Last checkin," \--file $fullreport/satellite_hosts_$timestamp.csv
#!---- Cleanup Parser ----!#
if [ $? -eq 0 ];
then
  awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{print $1,$21}' $fullreport/satellite_hosts_$timestamp.csv|uniq|awk '$2!=""'|awk '!/virt-who*/{print }'|sed 1d|awk -F, '{ OFS = FS;command="date -d " "\"" $2 "\""  " +%s
";command | getline $2;close(command);print}'| while IFS=, read -r col1 col2
    do
      if [ "$cutoff" -gt "$col2" ];
        then
          echo $col1","$col2 >> $runoff/parser_$timestamp.csv
          $haircut
        else
         :
      fi
  done
else
  echo "Satellite Hammer CSV failure -- $timestamp" >/dev/stderr
fi
