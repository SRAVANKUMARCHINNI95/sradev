#****************************************************************************************************************************************************
# * Copyright (C) 1998-2016 Connected Devices, Innominds Software Inc.
# *
# * This file is part of Connected Devices Project
# *
# * Connected Devices Project and associated code can not be copied
# * and/or distributed without the express permission of
# * Innominds Software Inc. and/or it subsidiaries
# *
# * Description: This script executes the MO call test case.
# * For any modification contact @Ramamohan (rbandapalli@innominds.com)
#*****************************************************************************************************************************************************
#use strict;
#use warnings;
my $mt_num = "04046126700";
my $mt_pin = "4357";
my $call_status;
my $lresult;

sub mo_call_test
{
   my @result = `adb shell getprop | grep "gsm" | grep "gsm.sim.state"`;
   print @result;
   my @matches = grep { /READY/ } @result;
   if (scalar @matches == 0)
   {
      $lresult = "NO-SIM";
      print $lresult;
      return $lresult;
   }
   system("adb wait-for-device shell input keyevent 82");
   system("adb wait-for-device shell input keyevent 3");
   $call_status=`adb shell dumpsys telephony.registry | grep mCallState`;
   if($call_status=~m/mCallState=2/)
   {
      print("Call already connected and in progress...\n");
      print("Ending the call \n");
      system("adb shell input keyevent KEYCODE_ENDCALL");
      #$lresult = "FAILED";
   }
   print("Connecting the call to $mt_num...\n");
   system("adb shell am start -a android.intent.action.CALL -d tel:$mt_num");
   sleep(5);
   #system("adb shell am start -a android.intent.action.CALL -d tel:$mt_pin");
   $call_status=`adb shell dumpsys telephony.registry | grep mCallState`;
   if($call_status=~m/mCallState=2/)
   {
      print("successfully connected a call,call in progress \n");
      print("\n Ending the call \n");
      system("adb shell input keyevent KEYCODE_ENDCALL");
      $lresult = "PASSED";
   }
   else
   {
      print("unable to connecting a call to $mt_num...\n");
      $lresult = "FAILED";
   }
   sleep(2);
   return $lresult;
}

sub mt_call_test
{
   my $mt_num = "04046126700,4357";

   my @result = `adb shell getprop | grep "gsm" | grep "gsm.sim.state"`;
   print @result;
   my @matches = grep { /READY/ } @result;
   if (scalar @matches == 0)
   {
      $lresult = "NO-SIM";
      print $lresult;
      return $lresult;
   }
   system("adb wait-for-device shell input keyevent 82");
   system("adb wait-for-device shell input keyevent 3");
   $call_status=`adb shell dumpsys telephony.registry | grep mCallState`;
   if($call_status=~m/mCallState=2/)
   {
      print("Call already connected and in progress...\n");
      print("Ending the call \n");
      system("adb shell input keyevent KEYCODE_ENDCALL");
      #$lresult = "FAILED";
   }
   print("Connecting the call to $mt_num...\n");
   system("adb shell am start -a android.intent.action.CALL -d tel:$mt_num");
   sleep(3);
   $call_status=`adb shell dumpsys telephony.registry | grep mCallState`;
   if($call_status=~m/mCallState=2/)
   {
      print("successfully connected a call,call in progress \n");
      sleep(15);
      system("adb shell dumpsys telephony.registry | grep 'mCallState\|mCallIncomingNumber' | grep 'mCallIncomingNumber'");
      sleep(3);
      system("adb shell input keyevent KEYCODE_CALL");
      sleep(2);
      $call_status=`adb shell dumpsys telephony.registry | grep mCallState`;
      if($call_status=~m/mCallState=2/)
      {
            $lresult = "PASSED";
            print("Ending the call \n");
            system("adb shell input keyevent KEYCODE_ENDCALL");

      }
      else
      {
         print("unable to connecting a call to $mt_num...\n");
         $lresult = "FAILED";
      }
  }
   else
   {
      print("unable to connecting a call to $mt_num...\n");
      $lresult = "FAILED";
   }
   return $lresult;
}
sub sms_test
{
   my @result = `adb shell getprop | grep "gsm" | grep "gsm.sim.state"`;
   print @result;
   my @matches = grep { /READY/ } @result;
   if (scalar @matches == 0)
   {
      $lresult = "NO-SIM";
      print $lresult;
      return $lresult;
   }
   $ret = system("adb shell am start -a android.intent.action.SENDTO -d sms:9963638090 --es sms_body 'SMS BODY GOES HERE' --ez exit_on_sent true");
   sleep(4);
   #$ret = system("adb shell input keyevent 22");
   $ret = system("adb shell input tap 1000 515");
   sleep(4);
   #$ret = system("adb shell input keyevent 66");
   $ret = system("adb shell input tap 560 945");
   print "SMS here $ret";
   sleep(4);
   if(!$ret)
   {
            $lresult = "PASSED";

   }
   else
   {
         $lresult = "FAILED";
   }
   return $lresult;
}
1;
