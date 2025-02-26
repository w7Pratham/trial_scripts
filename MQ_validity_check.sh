#!/bin/bash

# Get the current username
current_user=$(whoami)

# Check if the user is arther or jasper
if [ "$current_user" == "arther" ] || [ "$current_user" == "jasper" ]; then
  echo "User is $current_user. Running the next part of the script..."
  # Add the next part of your script here
else
  echo "User is not arther or jasper. Exiting."
  exit 1
fi