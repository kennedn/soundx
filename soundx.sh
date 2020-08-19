#!/bin/bash
userSelect=$1
#parse pacmd output to get an array of index numbers from sinks
idxArr=($(pacmd list-sinks | grep index: | awk '{print $NF}'))

print_help()
{
  exec_name=$(basename $0)
  echo "${exec_name} allows changing of pulseaudio sinks in terminal, usage:"
  echo
  echo "${exec_name} [OPTIONS] [index or card_name]"
  echo -e "-h, --help\n\tThis dialog."
  echo -e "-l, --list\n\tList available card_name's"
  echo -e "-i, --interactive\n\tInteractive selection mode"
  exit 1
}


#validate if user is requesting interactive mode
if $([ "$1" = "-i" ] || [ "$1" = "--interactive" ]) && [ $# -eq 1 ]; then
  # Maintain loop until userSelect isn't empty
  userSelect=
  while [ -z "$userSelect" ]; do
    # Print Header
    echo    "Available Sound Sinks"
    echo
    echo -e "#\tDescription"
    echo    "--------------------------"
    # for each sink
    for ((i=0;i<${#idxArr[@]};i++)); do
      # Print user friendly number instead of semi-random real idx value
      echo -en "$((i+1))\t"
      # Isolate card information block and index line based on current i
      idx_block="$(pacmd list-sinks | grep -A 99999 "index: ${idxArr[$i]}")"
      idx_line="$(echo "${idx_block}" | head -n 1)"
      # Extract alsa.name from idx_block, pad with spaces so that \t's behave
      desc=$(echo "${idx_block}" | grep "alsa.name" | head -n 1 | awk -F\" '{print $2}')
      desc+="               "
      # Highlight desc if the idx_line contains a *
      if [[ "${idx_line}" =~ "*" ]]; then
        echo -e "$(tput smso)${desc:0:18}$(tput rmso)"
      else
        echo -e "${desc:0:18}"
      fi
    done
    echo    "--------------------------"
    # Prompt for user input of number
    read -rp "Enter #: " tempInput
    # If tempInput isn't empty, is a number and is positive, lookup in idxArr array
    if [ -n "${tempInput}" ] &&  [ ${tempInput} -eq ${tempInput} ] 2> /dev/null && [ "${tempInput}" -gt 0 ]; then
       userSelect="${idxArr[$((tempInput - 1))]}"
    fi
    # If lookup never happened (empty), print error and repeat
    if [ -z "${userSelect}" ]; then
      userSelect=
      clear
      echo "Please enter a value between 1 and ${#idxArr[@]}" 
      read
      clear
    fi
  done
# List available sinks
elif $([ "$1" = "-l" ] || [ "$1" = "--list" ]) && [ "$#" -eq 1 ]; then
  pacmd list-sinks | grep -A 1 index: | grep "<.*>$" | sed 's/<\(.*\)>$/\1/' | awk '{print $NF}'
  exit 0
# Print help message
elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  print_help
fi


#Check if userSelect was specified via CLI or in interactive mode
if [ -z "$userSelect" ]; then
  echo -e "Please specify a valid card name or number" 
  exit 3
#If userSelect isn't a number, assume the user is looking up card name and get index from that
elif ! [ ${userSelect} -eq ${userSelect} ] 2> /dev/null; then
  userSelect=$(pacmd list-sinks | grep -A 1 index: | grep -B 1 "${userSelect}" | head -n 1 | awk '{print $NF}')
fi

# If userSelect is still empty, print an error
if [ -z "${userSelect}" ]; then
  echo -e "No card by that number or name exists"
  exit 3
fi

#parse pacmd output to get an array of index for active sound inputs
idxArr=($(pacmd list-sink-inputs | grep index: | awk '{print $NF}'))

#iterate through sound inputs and move over to new sink
for idx in ${idxArr[@]}; do
  pacmd move-sink-input $idx $userSelect  
done

# Use pactl to change default sink since new inputs don't follow with pacmd
pactl set-default-sink $userSelect

