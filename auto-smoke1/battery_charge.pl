#/************************************************************************
# * Copyright (C) 1998-2016 Connected Devices, Innominds Software Pvt Ltd.
# *
# * This file is part of Connected Devices Project
# *
# * Connected Devices Project and associated code can not be copied
# * and/or distributed without a written permission of
# * Innominds Software Pvt Ltd., and/or it subsidiaries
# *
# * Description: This module invokes when smotest.pl script calls battery_test
#
# * For any modification contact @Ramamohan (rbandapalli@innominds.com)
# ************************************************************************/

#!/usr/bin/perl
use strict;
use warnings;
my $lresult;
my $b_v1;
my $b_v2;
my $battery_level;

sub battery_test()
{
   print "Battery test execution started ...\n";
   system("adb shell am start -a android.intent.action.MAIN -c android.intent.category.HOME");
   $b_v1=`adb shell dumpsys battery | grep level | cut -d ":" -f2`;
   print "Analysing the  battery voltage...This will take 2 minutes..\n";
   sleep(60);
   $b_v2=`adb shell dumpsys battery | grep level | cut -d ":" -f2`;
   $battery_level=`adb shell dumpsys battery | grep level | cut -d ":" -f2`;
   if($b_v2 < 10)
   {
      print "Device is running on $battery_level(low battery), please plugin the charger\n";
      exit();
   }
   else
   {
      if($battery_level == 100 && $b_v1 < $b_v2)
      {
         $lresult = "PASSED";
      }
      elsif($battery_level != 100 && $b_v1 > $b_v2)
      {
         $lresult = "FAILED";
         print "First battery calculation is greater than second\n"
      }
      elsif($battery_level != 100 && $b_v1 < $b_v2)
      {
         $lresult = "PASSED";
         print "First battery calculation is lesser than second\n"
      }
      elsif($battery_level != 100 && $b_v1 eq $b_v2)
      {
         $lresult = "PASSED";
         print "First battery calculation is equal to second \n"
      }
      print "Battery test execution has completed ...\n";
      return  $lresult;
   }
}
1;
