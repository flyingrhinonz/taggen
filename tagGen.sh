#!/bin/bash

# Cable tags are 6 digits long which means this code will be effective until
# 29 July 2397 (epoch 13492928511), after which you'll need to start using
# 7 digit cable tags.

set -o nounset
set -o errtrace
set -o errexit
set -o pipefail
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/sbin

declare -a ConversionDigits=( 0 1 2 3 4 5 6 7 8 9 A C E F G H J K L M N P R T V W X Y )
    # ^ We skip letters that can be easily confused with numbers or other letters.
    #   Eg: 1/I , 0/D,O,Q , 2/Z, 5/S , V/U , 8/B
declare -i CurrentEpoch
declare BcBase28Epoch
declare -i Counter
declare NonStop

echo "For single output use:  $0 single   else it runs nonstop"
echo "Press ctrl-c to stop"
echo
echo "Epoch time    Base-28 conversion           Cable tag"
echo "----------    ------------------           ---------"

NonStop=${1:-nonstop}

while :
    do
    CurrentEpoch="$(date +%s)"
        # ^ Simple current time in epoch, eg: 1603573910
    BcBase28Epoch="$(echo "obase=28;ibase=10;${CurrentEpoch}" | bc)"
        # ^ bc converts the epoch integer to base-28, eg: 03 09 04 25 02 24 22
    echo -n "${CurrentEpoch} , ${BcBase28Epoch}  ====>  "

    Counter=1
    for Looper in ${BcBase28Epoch}
        # ^ Loop over the base-28 string. It is already conveniently space-delimited
        #   so a for loop works well, so we simply convert each field separately.
        do
        (( ${Counter} < 7 )) && echo -n "${ConversionDigits[10#$Looper]}"
            # ^ Print only the first 6 chars. The least significant digits are not
            #   printed (at present we have 7 digits from the epoch conversion).
            #
            #   10#$Looper explained:
            #   We want to get the value from array ConversionDigits which is stored
            #   at offset Looper. The bash function for this is {ArrayName[#Offset]} .
            #   However, bc is giving us a base-28 value in the form of a base-10
            #   number WITH leading zeros,
            #   so while ${ConversionDigits[18]} works, ${ConversionDigits[08]} will
            #   give this error:
            #       bash: 08: value too great for base (error token is "08")
            #   because leading 0 means a base 8 value - which is also why
            #   ${ConversionDigits[06]} will work!
            #   The solution is to tell bash that we're supplying a base-10 value
            #   regardless of the leading zeros by specifying 10 before the #
            #   yielding [10#$Looper] .

        (( ${Counter} == 3 )) && echo -n " "
            # ^ For visual formatting only - print a space after 3 chars
        (( Counter += 1 ))
    done

    echo    # End of line. Previous echo's were -n (stay on same line).

    [[ "${NonStop}" == "single" ]] && break
    sleep 30
        # ^ Give it enough time for the 6th digit to change. Remember:
        #   - The 7th digit is the seconds tick
        #   - We're running base-28
        #   - We want to keep the tag short, so we'll keep only 6 digits
        #   - Better to keep the first 6 digits so that tagGen will be useful
        #       for a long time to come without changes, and without fear that
        #       the codes will repeat.
        #   - You won't be tagging cables every second so the delay won't matter.
done

exit 0

