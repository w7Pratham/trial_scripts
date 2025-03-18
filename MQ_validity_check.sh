#!/bin/bash

# Get the current username
current_user=$(whoami)

# Check if the user is arther or jasper
if [ "$current_user" == "arther" ] || [ "$current_user" == "jasper" ]; then
  echo "User is $current_user. Running the next part of the script..."
  
  # Check if the folder with the same name exists in ~/Project/WORK/
  user_folder="$HOME/Project/WORK/$current_user"
  if [ -d "$user_folder" ]; then
    echo "Folder $user_folder exists."
    
    # Check if listed.kdb file exists in the folder
    if [ -f "$user_folder/listed.kdb" ]; then
      echo "Yes, listed.kdb file is present in $user_folder."
      
      # Grep the date from the To: field
      to_date=$( "$user_folder/listed.kdb")
      echo "The date from the To: field is: $to_date"
    else
      echo "No, listed.kdb file is not present in $user_folder."
    fi
  else
    echo "Folder $user_folder does not exist."
  fi
else
  echo "User is not arther or jasper. Exiting."
  exit 1
fi
