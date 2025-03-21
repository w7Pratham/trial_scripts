#!/bin/bash

# Get the current username
current_user=$(whoami)

# Check if the user is arther or jasper
if [ "$current_user" == "shiv" ] || [ "$current_user" == "jasper" ]; then
  echo "User is $current_user. Running the next part of the script..."
  
  # Extract the Status column from the file
  statuses=$(cat /home/shiv/Project/WORK/arther/status_check_data.txt | awk -F"|" 'NR>2{print $3}' )

  # Check if all statuses are START
  all_start=true
  for status in $statuses; do
    if [ "$status" != "START" ]; then
      all_start=false
      break
    fi
  done

  if [ "$all_start" = true ]; then
    echo "All statuses are START."
  else
    echo "There is an issue with the statuses."
  fi

else
  echo "User is not arther or jasper. Exiting."
  exit 1
fi