#!/bin/bash

set -o nounset
set -o errtrace
set -o errexit
set -o pipefail
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/sbin

declare -r ScriptVersion="Cable tag generator v1.02 , 2018-08-11 by Kenneth Aaron"
declare -r ProcID="$(echo $$)"   # Script process ID for logging purposes
declare -r ScriptName="TagGen"        # Keep this 10 or less characters to ensure log file formatting
declare -r CurrentUser="$(id -un)"
declare -i LogLevel=7
declare -a ConversionDigits=( 0 1 2 3 4 5 6 7 8 9 A C E F G H J K L M N P R T V W X Y )
declare -i CurrentEpoch
declare BcBase28Epoch
declare -i Counter
declare NonStop

echo "${ScriptVersion}"
echo "  For single output use  \`$0 single'  else it runs nonstop"
echo "  Press ctrl-c to stop"
echo

NonStop=${1:-nonstop}
echo "${NonStop} run"

while :
    do
    CurrentEpoch="$(date +%s)"
    BcBase28Epoch="$(echo "obase=28;ibase=10;${CurrentEpoch}" | bc)"
    echo -n "${CurrentEpoch} , ${BcBase28Epoch}  ====>  "

    Counter=0
    for Looper in ${BcBase28Epoch}
        do
        (( ${Counter} != 6 )) && echo -n "${ConversionDigits[10#$Looper]}"
        (( ${Counter} == 2 )) && echo -n " "
        (( Counter+=1 ))
    done
    echo
    [[ "${NonStop}" == "single" ]] && break
    sleep 31
done

exit 0

