#/************************************************************************
# * Copyright (C) 1998-2016 Connected Devices, Innominds Software Pvt Ltd.
# *
# * This file is part of Connected Devices Project
# *
# * Connected Devices Project and associated code can not be copied
# * and/or distributed without a written permission of
# * Innominds Software Pvt Ltd., and/or it subsidiaries
# *
# * Description: This module invokes when Smoketest.pl script valls the wifi_accesspoint test
#
# * For any modification contact @Ramamohan (rbandapalli@innominds.com)
#************************************************************************/
#!/usr/bin/perl
use strict;
use warnings;
my $wifi_status=0;
my $lresult;

sub wifi_check_accesspoint
{
    $wifi_status=`adb shell dumpsys wifi | grep "Wi-Fi is"`;
    print("$wifi_status\n");
}

sub wifi_accesspoint
{
   my $ret = `adb logcat | timeout 20s grep -m1 "ActivityManager: Crashing"`;
   if ($ret =~ m/Crashing/)
   {
      system("adb shell input keyevent 23");
      system("adb shell input keyevent 23");
      system("adb shell input keyevent 23");
      system("adb shell input keyevent 23");
   }

   system("adb shell input keyevent 3");
   #system("adb root");
   wifi_check_accesspoint();
   if($wifi_status=~m/Wi-Fi is disabled/)
   {
         print("wifi is disabled...enabling the wifi \n");
         system("adb shell am start -a android.intent.action.MAIN -n com.android.settings/.wifi.WifiSettings");
         system("adb shell input keyevent 19");
         system("adb shell input keyevent 19");
         system("adb shell input keyevent 23");
         sleep(2);
   }
   $lresult = internet_check();
   return $lresult;
}
sub internet_check
{
   system("adb shell input keyevent 3");
   system("adb shell am start -a android.intent.action.VIEW 'http://www.youtube.com/watch?v=YRhFSWz_J3I'");
   sleep(30);
   system("adb shell input keyevent 85");
   my $result = system("adb logcat | timeout 20s grep 'audio_hw_primary: start_output_stream:'");
   if ($result){
       print "Youtube browser streaming...\n";
       $lresult = "PASSED"
   }
   else{
       $lresult = "FAILED";
       print "Youtube streaming failed \n"
      }
   return $lresult;
}

1;
