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
    #   This results in 28 usable characters, hence base-28.
declare Mode="nonstop"


function DisplayHelp {
cat <<EOF

$0 With no arguments - generates tags nonstop. Press Ctrl-c to stop.
-h        Display this help message and exit.
-s        Single mode - generate one tag and exit.
-n        Nonstop mode - generate tags nonstop - press ctrl-c to stop.
-d <TAG>  Decode <TAG> back to epoch. <TAG> must be supplied with no spaces!

EOF
}


function RunTagGen {
    declare BcBase28Epoch
    declare -i CurrentEpoch
    declare -i Counter

    echo "Epoch time     Base-28 conversion           Cable tag"
    echo "----------     ------------------           ---------"

    while :
        do
        CurrentEpoch="$(date +%s)"
            # ^ Simple current time in epoch, eg: 1603573910
        BcBase28Epoch="$(echo "obase=28;ibase=10;${CurrentEpoch}" | bc)"
            # ^ bc converts the epoch integer to base-28, eg: " 03 09 04 25 02 24 22"
        BcBase28Epoch="${BcBase28Epoch##[[:blank:]]}"
            # ^ bc gives a string with a leading space. Doesn't affect
            #   the loop but better to have a clean string.
        echo -n "${CurrentEpoch}  =  ${BcBase28Epoch}  ====>  "

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

        [[ "${Mode}" == "single" ]] && break
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
}


function RunLookupTag {
    declare -i Epoch=0
    declare -i Power=1
    InputTag="${InputTag^^}"    # Uppercase the string
    echo "Decoding tag: \"${InputTag}\""

    # Check for tag length of precisely 6 chars:
    (( ${#InputTag} != 6 )) && \
        {
        echo "ERROR: tag must be precisely 6 chars with no spaces"
        exit 1
        }

    # Check if all supplied chars exist within the array of ConversionDigits:
    for CharLooper in {0..5}
        do
        SelectedChar="${InputTag:CharLooper:1}"
        [[ ! "${ConversionDigits[*]}" =~ "${SelectedChar}" ]] && \
            {
            echo "ERROR: Illegal character: ${SelectedChar}"
            exit 1
            }
        done

    # Calculate the epoch from the supplied tag:
    for CharLooper in {5..0}
        # ^ Work backwards in tag from least significant digit
        do
        SelectedChar="${InputTag:CharLooper:1}"

        for ArrayOffset in {0..27}
            do
            [[ "${SelectedChar}" == "${ConversionDigits[ArrayOffset]}" ]] && break
            done

        (( Epoch += ArrayOffset * (28 ** Power) ))
        (( Power += 1 ))
        done

    echo "Epoch = ${Epoch}"
    echo "In local time of this machine = $(date -d @${Epoch})"
    exit 0
}


# Main program follows:

(( $# == 0 )) && \
    {
    Mode="nonstop"
    RunTagGen
    }

(( $# > 0 )) && \
    {
    [[ "${1}" == "-h" ]] && \
        {
        DisplayHelp
        exit 0
        }
    [[ "${1}" == "-s" ]] && \
        {
        Mode="single"
        RunTagGen
        exit 0
        }
    [[ "${1}" == "-n" ]] && \
        {
        Mode="nonstop"
        RunTagGen
        exit 0
        }
    [[ "${1}" == "-d" ]] && \
        {
        (( $# > 1 )) && \
            {
            Mode="lookup"
            InputTag="${2}"
            RunLookupTag
            exit 0
            } || {
            echo "ERROR: Not enough arguments. Expecting: $0 -i <TAG>"
            exit 1
            }
        }
    echo "ERROR: Unknown argument ${1}"
    exit 1
    }

echo "ERROR: Shouldn't reach this line"
exit 1

