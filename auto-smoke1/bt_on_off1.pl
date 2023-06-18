#/************************************************************************
# * Copyright (C) 1998-2016 Connected Devices, Innominds Software Pvt Ltd.
# *
# * This file is part of Connected Devices Project
# *
# * Connected Devices Project and associated code can not be copied
# * and/or distributed without a written permission of
# * Innominds Software Pvt Ltd., and/or it subsidiaries
# *
# * Description: This module script called when smoketest invokes the
#                btcheck.
#* For any modification contact @Ramamohan (rbandapalli@innominds.com)
#************************************************************************/
#!/usr/bin/perl
use strict;
use warnings;
my $wifi_status=0;
my $lresult;

sub wifi_check_accesspoint
{
system("adb shell svc wifi enable");
system("adb root");
system("adb remount");
system("adb disable-verity");
system("adb reboot");
system("adb wait-for-device");
system("adb root");
system("adb remount");
system("adb push WifiConfigStore.xml /data/misc/wifi/");
system("adb remount");
}
wifi_check_accesspoint();
print "wifi completed";
