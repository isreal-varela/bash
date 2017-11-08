#!/bin/bash
#=== GeoIP from CLI
#=== Usage: ./geoip 123.123.123.123 124.124.124.124


### Check to see if we are getting 200 responses from GeoIPTool.com
GEOIP_CHECK=$(curl -kw '%{http_code}\n' -o /dev/null -s 'https://geoiptool.com/api/view/' | awk '{if ($0 > 200) print "fail"; else print}')

echo "test" | awk 'BEGIN{printf "%-18s %-11s %15s %16s %60s\n","IP","City","Region","Country","Hostname"}'

### Loop over the number of passed IPs we got as input
for IPs in $@
do
  ### Set IP variable to the current one from our $@ argument list
  IP="$IPs"
  ### If we don't get a 200 from GeoIPTool.com, print the IP and host
  if [[ $GEOIP_CHECK -eq "fail" ]]
  then
    DISPLAY=$(echo "$IP" | awk '{printf "%15s ",$1}'; echo -n $(host $IP | awk '{print $NF}'))
    echo $DISPLAY
    echo $GEOIP_CHECK
  else
    ### Print out IP, City, Region, Country, and Hostname of each IP
    GEOIP=$(curl -m10 https://geoiptool.com/api/view/?ip=$IP 2>/dev/null)
    DISPLAY=$(echo "$IP"; echo "$GEOIP" | awk 'gsub(",","\n")' | awk '/city|country_name|region_name|hostname/ {gsub("[{\"]",""); gsub("(^ |city: |hostname: |region_name: |country_name: )",""); print}' | awk '{printf "%s|",$0}' | awk -F"|" '{print $1,$2,$4}'; echo -n $(host $IP | awk '{print $NF}'))
    echo $DISPLAY | awk '{printf "%-18s %-20s %-15s %s %s %60s\n",$1,$2,$3,$4,$5,$6,$7}'
    ### Sleep for 1 second and maybe longer to avoid GeoIPTools.com blocking IP
    sleep 5
  fi
done
