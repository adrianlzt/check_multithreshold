# Check Multi Thresholds
Check your script with different values for warning and critical depending
of the current hour

example:
check_multithreshold.sh -x "/usr/lib64/nagios/plugins/check_tcp -H 127.0.0.1 -p 22" -t 0000-0800 -w 1 -c 2 -t 0800-2359 -w 5 -c 10

Adrian Lopez
