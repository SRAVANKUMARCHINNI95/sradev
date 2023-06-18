#!/bin/bash

SSID="sravan"
PASSWORD="sra123456"

# Enable Wi-Fi
adb shell svc wifi enable

# Wait for Wi-Fi to turn on
sleep 2

# Open Wi-Fi settings
adb shell am start -a android.settings.WIFI_SETTINGS

# Wait for Wi-Fi settings to open
sleep 2

# Tap on "Add network" button
adb shell input keyevent 82  # Unlock device (if needed)
adb shell input swipe 500 1600 500 400 200  # Scroll to the bottom (adjust the coordinates as needed)
adb shell input tap 500 1600  # Tap on "Add network" button (adjust the coordinates as needed)
sleep 2

# Input SSID
adb shell input text "$SSID"

# Move focus to the password field
adb shell input keyevent 20

# Input password
adb shell input text "$PASSWORD"

# Tap on "Connect" button
adb shell input keyevent 66

echo "Wi-Fi network added: $SSID"

# Check if the device is connected to the specified Wi-Fi network
connected_ssid=$(adb shell "dumpsys wifi | grep 'SSID:' | awk -F '\"' '{print \$2}'")
if [[ "$connected_ssid" == "$SSID" ]]; then
    echo "Connected to Wi-Fi network: $SSID"
else
    echo "Failed to connect to Wi-Fi network: $SSID"
fi

