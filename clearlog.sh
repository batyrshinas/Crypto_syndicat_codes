#!/bin/sh
LINECOUNTS=(`cat /var/log/syslog | wc -l`)

if [ $LINECOUNTS -gt "1000" ];
    then
        echo "Recreating syslog file due to lines "$LINECOUNTS" are more than 1000 lines"
        truncate -s 0 /var/log/syslog
        sleep 5
else
        echo "syslog file having line count "$LINECOUNTS" less than 1000}"
fi
/bin/systemctl restart syslog
exit
