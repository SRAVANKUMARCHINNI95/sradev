#/************************************************************************
# * Copyright (C) 1998-2016 Connected Devices, Innominds Software Pvt Ltd.
# *
# * This file is part of Connected Devices Project
# *
# * Connected Devices Project and associated code can not be copied
# * and/or distributed without a written permission of
# * Innominds Software Pvt Ltd., and/or it subsidiaries
# *
# * Description: This script invokes when smoketest.pl script calls the airplanemode_test
#
# * For any modification contact @Ramamohan (rbandapalli@innominds.com)
#************************************************************************/
#!/usr/bin/perl
use strict;
use warnings;
my $AP_status=0;
my $lresult;
sub ap_mode_check
{
   chomp(my $status = `adb shell settings get global airplane_mode_on`);

   if ($status == 0){
      $AP_status="UNSOL_RESPONSE_RADIO_STATE_CHANGED RADIO_OFF";
   }
   elsif($status ==1 ) {
      $AP_status="UNSOL_RESPONSE_RADIO_STATE_CHANGED RADIO_ON";
   }
   else {
      print "No matching AP_MODE return \n";
      $lresult = "FAILED";
      return $lresult;
   }

}
sub ap_mode_OFF()
{
   print("Disabling the Airplane mode \n");
   system("adb logcat -c -b radio");
   system("adb wait-for-device shell settings put global airplane_mode_on 0");
   system("adb wait-for-device shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true > APM.txt");
}
sub airplanemode_test
{
   print "AP Mode test execution started...\n";
   system("adb shell input keyevent 82");
   system("adb shell am start -a android.intent.action.MAIN -c android.intent.category.HOME > home.txt");
   sleep(3);
   ap_mode_check();
   print "AP MODE Status is $AP_status \n";

   if($AP_status=~m/UNSOL_RESPONSE_RADIO_STATE_CHANGED RADIO_OFF/)
   {
       print("Enabling the Airplane mode \n");
       system("adb logcat -c -b radio");
       system("adb shell am start -a android.settings.AIRPLANE_MODE_SETTINGS > APM.txt");
       sleep(2);
       system("adb wait-for-device shell settings put global airplane_mode_on 1");
       sleep(2);
       system("adb wait-for-device shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true > APM.txt");
       ap_mode_check();
       if($AP_status=~m/UNSOL_RESPONSE_RADIO_STATE_CHANGED RADIO_ON/)
       {
          $lresult = "PASSED";
       }
       else{
          $lresult = "FAILED";
       }
   }
   elsif($AP_status=~m/UNSOL_RESPONSE_RADIO_STATE_CHANGED RADIO_ON/)
   {
      print("Disabling the Airplane mode \n");
      system("adb logcat -c -b radio");
      system("adb wait-for-device shell settings put global airplane_mode_on 0");
      sleep(2);
      system("adb wait-for-device shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true > APM.txt");
      sleep(2);
      ap_mode_check();
      if($AP_status=~m/UNSOL_RESPONSE_RADIO_STATE_CHANGED RADIO_OFF/)
      {
         $lresult = "PASSED";
      }
      else{
         $lresult = "FAILED";
      }
   }
   print "AP Mode Test execution completed...\n";
   
   return $lresult;
}
1;
