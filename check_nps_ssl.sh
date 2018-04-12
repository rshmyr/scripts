#!/bin/bash

WARN=20
CRIT=10

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKOWN=3

exp_date=$(openssl x509 -inform PEM -noout -enddate -in nps.meteogroup.net.cer | cut -d"=" -f2)
echo $exp_date
exp_epoch_date=$(date -d "$exp_date" +%s)
echo $exp_epoch_date
now_epoch=$(date +%s)

exp_days=$(( ($exp_epoch_date - $now_epoch) / (3600 * 24) ))
echo $exp_days

if [ $exp_days -ge $WARN ]; then
   echo "OK - SSL for NPS.METEOGROUP.NET is OK and will be expired n $exp_days on $exp_date | DAYS LEFT=$exp_days;$WARN;$CRIT"
   exit $STATE_OK
elif [ $exp_days -lt $CRIT ]; then
   echo "CRITICAL -  SSL for NPS.METEOGROUP.NET will be expired in $exp_days days on $exp_date | DAYS LEFT=$exp_days;$WARN;$CRIT"
   exit $STATE_CRITICAL
elif [ $exp_days -lt $WARN ] && [ $exp_days -ge $CRIT  ]; then
   echo "WARNING - SSL for NPS.METEOGROUP.NET will be expired in $exp_days days on $exp_date | DAYS LEFT=$exp_days;$WARN;$CRIT"
   exit $STATE_WARNING
else
   echo "UNKNOWN SITUATION"
   exit $STATE_UNKOWN
fi
