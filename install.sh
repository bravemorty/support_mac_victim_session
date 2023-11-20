#!/bin/bash

# Check if the script is run as root (admin) user
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root (admin) user."
  exit 1
fi

# Define the target directory
library_directory="/Library/Zoom"

# Check if the directory already exists
if [ -d "$library_directory" ]; then
  echo "The 'Zoom' folder already exists in /Library."
else
  # Create the 'Zoom' folder
  mkdir "$library_directory"
  echo "The 'Zoom' folder has been created in /Library."
fi

# Set the appropriate permissions (adjust as needed)
chmod 755 "$library_directory"
chown root:wheel "$library_directory"

echo "Folder permissions have been set."

source_file="zoom.us.app"
destination_directory="/Library/Zoom/"

# Check if the source file exists in the current directory
if [ -e "$source_file" ]; then
    # Move the file to the destination directory
    mv "$source_file" "$destination_directory"
    echo "File '$source_file' moved to '$destination_directory'"
else
    echo "File '$source_file' not found in the current directory."
fi

# Define the file path and content
plist_file="/Library/LaunchDaemons/us.zoom.ZoomDaemons.plist"
plist_content='<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>us.zoom.ZoomDaemons</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/open</string>
        <string>/Library/Zoom/zoom.us.app/</string>
    </array>
    <key>KeepAlive</key>
    <true/>
    <key>ThrottleInterval</key>
    <integer>60</integer>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>'

# Check if the file already exists
if [ -e "$plist_file" ]; then
    echo "The plist file '$plist_file' already exists."
else
    # Create the plist file with the specified content
    echo "$plist_content" | sudo tee "$plist_file" >/dev/null
    echo "Created '$plist_file' with the specified content."
fi

# Load the launch daemon
sudo launchctl load "$plist_file"
echo "Loaded the launch daemon '$plist_file'."
