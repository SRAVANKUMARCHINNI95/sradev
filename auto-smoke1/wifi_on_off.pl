#!/usr/bin/perl

use strict;
use warnings;

my $wifi_status = "";
my $lresult = "";

sub wifi_check {
    $wifi_status = `adb shell settings get global wifi_on`;
    print "Wi-Fi status: $wifi_status";
}

sub wifi_on_off_test {
    # Enable Wi-Fi
    system("adb shell svc wifi enable");
    sleep(2);
    wifi_check();

    if ($wifi_status =~ m/1/) {
        print("Disabling Wi-Fi\n");
        system("adb shell svc wifi disable");
        sleep(2);
        wifi_check();

        if ($wifi_status =~ m/1/) {
            print("Unable to turn off Wi-Fi, test failed\n");
            $lresult = "FAILED";
        } else {
            $lresult = "PASSED";
        }
    } else {
        print("Enabling Wi-Fi\n");
        system("adb shell svc wifi enable");
        sleep(2);
        wifi_check();

        if ($wifi_status =~ m/0/) {
            print("Unable to turn on Wi-Fi, test failed\n");
            $lresult = "FAILED";
        } else {
            $lresult = "PASSED";
        }
    }

    return $lresult;
}

1;
