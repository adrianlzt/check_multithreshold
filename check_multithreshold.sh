#!/bin/bash
 
#@
#@ ==============================================================================
#@
#@ Check Multi Thresholds
#@ Check your script with different values for warning and critical depending
#@ of the current hour
#@ 
#@ example:
#@ check_multithreshold.sh -x "/usr/lib64/nagios/plugins/check_tcp -H 127.0.0.1 -p 22" -t 0000-0800 -w 1 -c 2 -t 0800-2359 -w 5 -c 10
#@
#@ Adrian Lopez
#@ 
#@ ToDo:
#@   - Script which need multiparameter for critical and warning values. 
#@       Eg.:  check_load [-r] -w WLOAD1,WLOAD5,WLOAD15 -c CLOAD1,CLOAD5,CLOAD15
#@ 
#@ ==============================================================================
#@
 
# =============================================================================================================
# HELPER METHOD
# =============================================================================================================
 
function error()
{
  echo -e "\e[00;31m>`date +'%Y.%m.%d %H:%M:%S'` $LOG_VMNAME | ERROR | $1\e[00m"
}
 
# =============================================================================================================
# CMD DEFINITION
# =============================================================================================================
 
#@ usage
#@  - How to use the script
#@
#% 
function usage()
{
  echo ""
  echo "Check Multithreshold allows you to execute the same script with different warning and critical values"
  echo "depending in the current hour"
  echo ""
  echo "Usage:"
  echo "check_multithreshold.sh -x check_file -t HHMM-HHMM -w <range> -c <range> [ -t HHMM-HHMM -w <range> -c <range> ] ..."
  echo ""
  echo "Options:"
  echo " -x"
  echo "   Script to be executed"
  echo " -t"
  echo "   Time period in wich the next threshold will be applicated."
  echo "   The format is hour and minute of start - hour and minute of finish"
  echo " -w"
  echo "   Critical range that will be passed to the script"
  echo " -c"
  echo "   Critical range that will be passed to the script"
  echo ""
  echo "Several time periods and critical and warning ranges could be passed"
  echo ""
}
 
#% 
#@ check_param
#@  - Check that parameter is the expected one
#@
#% 
function check_param()
{
  if [[ $1 != $2 ]]; then
    error "Check parameter: '$1'. Should be $2"
    usage
    exit 1
 fi 
}

#% 
#@ check_regex
#@  - Check if parameter value is formated as expected
#@
#% 
function check_regex()
{
  if [[ ! ( $1 =~ $2 ) ]]; then
    error "Wrong parameter value: $1"
    usage
    exit 1
 fi 
}
 
#% 
#@ actualTimeIn 
#@  - Check if current time is inside the time period
#@
#% 
function actualTimeIn()
{
  startHour=${1%-*}
  endHour=${1#*-}
  currentHour=$(date +%H%M)
  if [[ ( $currentHour -gt $startHour ) && ( $currentHour -lt $endHour ) ]]; then
    return 0
  else
    return 1
  fi 
}
 
#@ check_regex
# =============================================================================================================
# MAIN BLOCK
# =============================================================================================================
# Return codes:

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
# exit ${STATE_OK}

if [[ $# -le 7 ]]; then
  error "Insuficient parameters"
  usage
  exit 1
fi

PARAM=$1
check_param $PARAM "-x"
shift

# Check and parameters to execute
EXEC_AND_PARAM=$1
EXEC=${EXEC_AND_PARAM%% *}
shift
if [[ ! -e $EXEC ]]; then
  error "$EXEC doesn't exists"
  exit 1
fi
if [[ ! -x $EXEC ]]; then
  error "$EXEC is not executable"
  exit 1
fi

# Check there is enough parameters
if [[ $(( $# % 6 )) -ne 0 ]]; then
  error "Insufficient parameters"
  usage
  exit 1
fi

# Cheking parameters
while [ $# -ge 6 ]
  do
    PARAM=$1
    shift
    check_param $PARAM "-t"
    TEMP=$1
    shift
    check_regex $TEMP \[0-9]{4}-[0-9]{4}\

    PARAM=$1
    shift
    check_param $PARAM "-w"
    WARN=$1
    shift
    check_regex $WARN \[0-9]+\

    PARAM=$1
    shift
    check_param $PARAM "-c"
    CRIT=$1
    shift
    check_regex $CRIT \[0-9]+\

    if actualTimeIn $TEMP; then
      echo "$EXEC_AND_PARAM -w $WARN -c $CRIT"
      break
    fi
done
