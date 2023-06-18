#!/usr/bin/perl

use strict;
use warnings;

# Function to check the display status
sub check_display_status {
    # ADB command to check the display status
    my $adb_command = 'adb shell dumpsys power | grep "Display Power: state="';

    # Execute the ADB command
    my $output = `$adb_command`;

    # Check if the output contains "state=ON"
    if ($output =~ /state=ON/) {
        return "ON";
    } elsif ($output =~ /state=OFF/) {
        return "OFF";
    } else {
        return "Unknown";
    }
}

# Function to turn on the display
sub turn_on_display {
    my $adb_command = 'adb shell input keyevent KEYCODE_WAKEUP';
    print "Checking Display ON\n";
    `$adb_command`;
}

# Function to turn off the display
sub turn_off_display {
    my $adb_command = 'adb shell input keyevent KEYCODE_SLEEP';
    print "Checking Display OFF\n";
    `$adb_command`;
}

# Function to check if both turning on and off the display are working correctly
sub display_check {
    # Call the turn_on_display function
    turn_on_display();

    # Sleep for a few seconds to allow the display to turn on
    sleep(5);

    # Call the check_display_status function after turning on the display
    my $on_status = check_display_status();

    # Call the turn_off_display function
    turn_off_display();

    # Sleep for a few seconds to allow the display to turn off
    sleep(5);

    # Call the check_display_status function after turning off the display
    my $off_status = check_display_status();

    # Check if both turning on and off the display were successful
    my $lresult;  # Corrected variable declaration
    if ($on_status eq "ON" && $off_status eq "OFF") {

        $lresult = "PASSED";
    } else {
        $lresult = "FAILED";
    }
    return $lresult;
}

