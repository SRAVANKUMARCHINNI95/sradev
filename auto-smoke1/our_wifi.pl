#!/usr/bin/perl

use strict;
use warnings;

#use Term::ADB;
#use Term::ADB;

my $adb = Term::ADB->new;

# Get the device serial number.
my $serial_number = $adb->get_device_serial_number();

# Get the WiFi SSID and password.
my $ssid = "sravan";
my $password = "sra123456";

# Connect to the WiFi access point.
$adb->shell("netcfg wlan0 ssid $ssid password $password");

# Check if the connection was successful.
my $output = $adb->shell("netcfg");

if ($output =~ /^wlan0/) {
  print "Successfully connected to WiFi access point $ssid.\n";
} else {
  print "Failed to connect to WiFi access point $ssid.\n";
}

