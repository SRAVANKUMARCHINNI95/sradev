#/************************************************************************
# * Copyright (C) 1998-2016 Connected Devices, Innominds Software Pvt Ltd.
# *
# * This file is part of Connected Devices Project
# *
# * Connected Devices Project and associated code can not be copied
# * and/or distributed without a written permission of
# * Innominds Software Pvt Ltd., and/or it subsidiaries
# *
# * Description: This script invokes when smoke_test.pl script calls the
# * boot_version test
#
# * For any modification contact @Ramamohan (rbandapalli@innominds.com)
#************************************************************************/
#!/usr/bin/perl
use strict;
use warnings;

my $lresult;

sub boot_version {
   system("adb wait-for-device shell reboot bootloader");
   system("fastboot devices");
   my $aboot_version = `fastboot getvar version-bootloader | grep "version-bootloader" | cut -d ":" -f2`;

   if ($aboot_version eq "") {
      $lresult = "PASSED";
   } else {
      $lresult = "FAILED";
   }

   system("fastboot reboot");
   
   #print "Result is $lresult\n";  # Print the value of $lresult before the return statement
   #my $ret = `adb logcat | grep -m1 "BOOT_COMPLETED"`;
   #print "my ret is $ret";
   system("adb wait-for-device");

   return $lresult;
}
1;

