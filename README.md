# Check Multi Thresholds
Check Multithreshold allows you to execute the same script with different warning and critical values
depending in the current hour

```
Usage:
check_multithreshold.sh -x check_file -t HHMM-HHMM -p PARAMS [ -t HHMM-HHMM -p PARAMS ] ...

Options:
 -x
   Script to be executed
 -t
   Time period in wich the next threshold will be applicated.
   The format is hour and minute of start - hour and minute of finish
   The period could not pass over 2359. So, 2200-0300 will not be valid.
 -p
   Parameters specific to the time period

Several time periods and critical and warning ranges could be passed

Example: check_multithreshold.sh -x "/usr/lib64/nagios/plugins/check_tcp -H 127.0.0.1 -p 22" -t 0000-0800 -p "-w 1 -c 2" -t 0800-2359 -p "-w 5 -c 10"
```

Adrian Lopez
