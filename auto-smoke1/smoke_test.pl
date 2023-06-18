# /************************************************************************
#  * Copyright (C) 1998-2016 Connected Devices, Innominds Software Pvt Ltd.
#  *
#  * This file is part of Connected Devices Project
#  *
#  * Connected Devices Project and associated code can not be copied
#  * and/or distributed without a written permission of
#  * Innominds Software Pvt Ltd., and/or it subsidiaries
#  *
#  * Description: Smoketest.pl script invokes the other test scripts to run
#                 Target such as display,battery,wifi etc.
#  * For any modification contact @Ramamohan (rbandapalli@innominds.com)
#************************************************************************/
#!/usr/bin/perl
my $systime;
use utf8;
use JIRA::Client;
do './ap_mode_on_off.pl';
do './mo_call.pl';
do './buildflashing.pl';
do './camera_on_off.pl';
do './wifi_on_off.pl';
do './bt_on_off.pl';
do './wifi_accesspoint_check.pl';
do './display_check.pl';
do './battery_charge.pl';
do './aboot_version.pl';
do './jira.pl';

use Time::Piece;
use 5.010;
my $inputkernel = $ARGV[0];
my $buildID = $ARGV[1];
print "kernel passd as $inputkernel \n";
my $date_time = `date -Is`;
print "date and time is $date_time";
my $log_path="./smoketestcases_result/";
print "log path is $log_path \n";
$date_time =~ tr/-,T,+,T,:,/_/;
chomp $date_time;
my $logfile="$log_path"."$date_time"."result.txt";
print "Checking for device...\n";
 my $product_type=`adb shell getprop ro.product.name`;
print "product type is $product_type";
my $product_type=`adb devices`;
print "adb devices are $product_type \n";
my $exec_date = localtime->strftime('%Y-%m-%d');
if (-f "$logfile")
{
   system("rm -rf $logfile");
}
if (!$product_type)
{
   open my $FH,">>", $logfile  or die("Cant open log file. $!");
   print $FH "No device is connected, exiting the script \n";
   close $FH;
   exit();
}
else{
   open my $FH,">>", $logfile  or die("Cant open log file. $!");
   system("adb wait-for-device shell svc power stayon usb");
   system("adb logcat -d > logcat.txt");

   my $mypwd = "15921039Ss\@";
   my $assignee = "schinni\@innominds.com";
   print "Creating the Test Object..!\n";
   my $ret = `ruby ./post_request.rb 'admin' '$mypwd'  https://cdtestcentral.innominds.com/api/create_execution.xml "<request> <project>Indra M Upgrade</project> <execution> <name>algizrt7_userdebug_daily-MPAA1-$buildID</name> <test_object>Platform_Smoke</test_object> <date>$exec_date</date> <tag_list>Platform_Smoke</tag_list><tag_list></tag_list><test_area> <name>Kernel - Generic</name> </test_area> <assigned_to>$assignee</assigned_to> </execution> </request>"`;
   print "Test object status -$ret\n";
   if($ret =~m/created/){
       print "test Object created for smoke\n";
   }
   else{
    print "Unable to create the test object\n";
   }
   print "****************************** Build Flash ******************************\n";
   $test = buildflashing();
   print $FH "Buildnumber : $buildID\n";
   print $FH "1. Build Flash - $test \n";
   print $test;
   $ret = `ruby ./post_request.rb 'admin' '$mypwd'  https://cdtestcentral.innominds.com/api/update_testcase_execution.xml '<request> <project>Indra M Upgrade</project> <execution>algizrt7_userdebug_daily-MPAA1-$buildID</execution> <testcase> <title>[OTA_01] flashall</title> <duration>620</duration> <step position="1" result="$test" comment="Result Posted from SmokeTest"></step> </testcase> </request>'`;
   print "$ret\n";
   print "Installing APK";
   system("adb shell svc data disable");
   sleep(3);
   system("adb install ./smoke-auto.apk");
   system("adb install ./smoke-autoTest.apk");
   system("adb shell svc data enable");
   sleep(2);
   system("adb shell am instrument -w -r -e class com.innominds.smokeautomation.GoogleAccountSetupTest com.innominds.smokeautomation.test/android.support.test.runner.AndroidJUnitRunner");
   sleep(3);
   print "****************************** Boot version ******************************\n";
   $test = boot_version();
   print "The boot version is $test";
   $ret = `ruby ./post_request.rb 'admin' '$mypwd'  https://cdtestcentral.innominds.com/api/update_testcase_execution.xml '<request> <project>Indra M Upgrade</project> <execution>algizrt7_userdebug_daily-MPAA1-$buildID</execution> <testcase> <title>[OTA_01] flashall</title> <duration>620</duration> <step position="1" result="$test" comment="Result Posted from SmokeTest"></step> </testcase> </request>'`;
   print "$ret\n";
   print $FH "2. Boot Version Check - $test \n";
   print $test
   print "before unlock";
   #unlock();
   print "****************************** Adb enumeration Test ******************************\n";
   my $ret = `adb devices`;
   print "adb is $ret";
   if ($ret){
      print $FH "3. Adb enumeration Test - PASSED \n";
      $test = "PASSED";
   }
   else{
    print $FH "3. Adb enumeration Test - FAILED \n";
    $test = "FAILED"
   }
   $ret = `ruby ./post_request.rb 'admin' '$mypwd'  https://cdtestcentral.innominds.com/api/update_testcase_execution.xml '<request> <project>Indra M Upgrade</project> <execution>algizrt7_userdebug_daily-MPAA1-$buildID</execution> <testcase> <title>[ADB_01] adb connectivity</title> <duration>620</duration> <step position="1" result="$test" comment="Result Posted from SmokeTest"></step> </testcase> </request>'`;
   print "$ret\n";
   print "****************************** Home Screen Test ******************************\n";
   my $result = system("adb shell am start -a android.intent.action.MAIN -c android.intent.category.HOME");
   if ($result != 0)
   {
      print $FH "4. Home Screen Test - FAILED \n";
      $test = "FAILED";
   }
   else{
      print $FH "4. Home Screen Test - PASSED \n";
      $test = "PASSED";
   }
   $ret = `ruby ./post_request.rb 'admin' '$mypwd'  https://cdtestcentral.innominds.com/api/update_testcase_execution.xml '<request> <project>Indra M Upgrade</project> <execution>algizrt7_userdebug_daily-MPAA1-$buildID</execution> <testcase> <title>[FWGEN_FS_04] Home Screen</title> <duration>620</duration> <step position="1" result="$test" comment="Result Posted from SmokeTest"></step> </testcase> </request>'`;
   print "$ret\n";
   print "****************************** Display check Test ******************************\n";
   $test = display_check();
   print $FH "5. Display Check - $test \n";
   $ret = `ruby ./post_request.rb 'admin' '$mypwd'  https://cdtestcentral.innominds.com/api/update_testcase_execution.xml '<request> <project>Indra M Upgrade</project> <execution>algizrt7_userdebug_daily-MPAA1-$buildID</execution> <testcase> <title>[MM_display_01] Suspend/Resume</title> <duration>620</duration> <step position="1" result="$test" comment="Result Posted from SmokeTest"></step> </testcase> </request>'`;
   print "$ret\n";
   print "****************************** Battery Test ******************************\n";
   $test = battery_test();
   print $FH "6. Battery Test - $test \n";
   $ret = `ruby ./post_request.rb 'admin' '$mypwd'  https://cdtestcentral.innominds.com/api/update_testcase_execution.xml '<request> <project>Indra M Upgrade</project> <execution>algizrt7_userdebug_daily-MPAA1-$buildID</execution> <testcase> <title>[WC_02] Wall Charging','BT On/Off Test</title> <duration>620</duration> <step position="1" result="$test" comment="Result Posted from SmokeTest"></step> </testcase> </request>'`;
   print "$ret\n";
   sleep(5);
   print "before home intent";
   my $result = system("adb shell am start -a android.intent.action.MAIN -c android.intent.category.HOME");
   #unlock();
   sleep(5);
   
   print "****************************** Airplane mode Test ******************************\n";
   $test = airplanemode_test();
   print $FH "8. Airplane Mode Check  - $test \n";
   $ret = `ruby ./post_request.rb 'admin' '$mypwd'  https://cdtestcentral.innominds.com/api/update_testcase_execution.xml '<request> <project>Indra M Upgrade</project> <execution>algizrt7_userdebug_daily-MPAA1-$buildID</execution> <testcase> <title>[FWTEL_FS_23] Aeroplane mode OFF</title> <duration>620</duration> <step position="1" result="$test" comment="Result Posted from SmokeTest"></step> </testcase> </request>'`;
   print "$ret\n";
   ap_mode_OFF();
   
   print "****************************** Bluetooh check ******************************\n";
   $test = btcheck();
    print "after bluetooth check intent";
   print $FH "7. BT On/Off Test - $test\n";
   $ret = `ruby ./post_request.rb 'admin' '$mypwd'  https://cdtestcentral.innominds.com/api/update_testcase_execution.xml '<request> <project>Indra M Upgrade</project> <execution>algizrt7_userdebug_daily-MPAA1-$buildID</execution> <testcase> <title>[BT_001]Bluetooth Enable/disable</title> <duration>620</duration> <step position="1" result="$test" comment="Result Posted from SmokeTest"></step> </testcase> </request>'`;
   print "$ret\n";
   
   print "****************************** WiFi on/off Test ******************************\n";
   $test = wifi_on_off_test();
   print $FH "9. WiFi On/Off Test - $test\n";
   $ret = `ruby ./post_request.rb 'admin' '$mypwd'  https://cdtestcentral.innominds.com/api/update_testcase_execution.xml '<request> <project>Indra M Upgrade</project> <execution>algizrt7_userdebug_daily-MPAA1-$buildID</execution> <testcase> <title>[WiFi_001] Enable / disable wifi and check for Access point list</title> <duration>620</duration> <step position="1" result="$test" comment="Result Posted from SmokeTest"></step> </testcase> </request>'`;
   print "$ret\n";

=pod
   $test = wifi_accesspoint();
   print $FH "10. WiFi AP Connect Test - $test\n";
   print $FH "11. Data browsing Test - - $test\n";
   $ret = `ruby ./post_request.rb 'admin' '$mypwd'  https://cdtestcentral.innominds.com/api/update_testcase_execution.xml '<request> <project>Indra M Upgrade</project> <execution>algizrt7_userdebug_daily-MPAA1-$buildID</execution> <testcase> <title>[WiFi_002]Connect to access point and Check internet connection through browsing</title> <duration>620</duration> <step position="1" result="$test" comment="Result Posted from SmokeTest"></step> </testcase> </request>'`;
   print "$ret\n";
=cut
   $test = camera_image_test();
   print $FH "12. Camera Image Test - $test \n";
   $ret = `ruby ./post_request.rb 'admin' '$mypwd'  https://cdtestcentral.innominds.com/api/update_testcase_execution.xml '<request> <project>Indra M Upgrade</project> <execution>algizrt7_userdebug_daily-MPAA1-$buildID</execution> <testcase> <title>[MM_cam_01] Camera Launch</title> <duration>620</duration> <step position="1" result="$test" comment="Result Posted from SmokeTest"></step> </testcase> </request>'`;
   print "$ret\n";
   
print "camera module start\n";
   $test = camera_video_test();
   print $FH "13. Camera Video Test - $test \n";


print "****************************** Audio playback Test ******************************\n";
   $test = audio_test();
   print $FH "14. Audio Test - $test \n";
   $ret = `ruby ./post_request.rb 'admin' '$mypwd'  https://cdtestcentral.innominds.com/api/update_testcase_execution.xml '<request> <project>Indra M Upgrade</project> <execution>algizrt7_userdebug_daily-MPAA1-$buildID</execution> <testcase> <title>[MM_audio_01] Play Audio mp3 format</title> <duration>620</duration> <step position="1" result="$test" comment="Result Posted from SmokeTest"></step> </testcase> </request>'`;
   print "$ret\n";
   
print "****************************** Video playback Test ******************************\n";
   $test = video_test();
   print $FH "15. Video Test - $test \n";
   $ret = `ruby ./post_request.rb 'admin' '$mypwd'  https://cdtestcentral.innominds.com/api/update_testcase_execution.xml '<request> <project>Indra M Upgrade</project> <execution>algizrt7_userdebug_daily-MPAA1-$buildID</execution> <testcase> <title>[MM_video_01] Play Video mp4 format</title> <duration>620</duration> <step position="1" result="$test" comment="Result Posted from SmokeTest"></step> </testcase> </request>'`;
   print "$ret\n";

   system("adb wait-for-device");

   my $kernel = `adb shell uname -a`;
   print "kernel is $kernel \n";
   print "passed is $inputkernel \n";
   if ($inputkernel){
      my @s = split / /,$inputkernel;
      my $testkernel =  @s[0];
      if (index($kernel,$testkernel) != -1)
      {
         print $FH "16. Kernel Version Check - PASSED\n";
         $test = "PASSED";
      }
      else{
         print $FH "16. Kernel Version Check - FAILED\n";
         $test = "FAILED";
       }
   }
   else{
      print $FH "16. Kernel Version Check - FAILED\n";
      $test = "FAILED";
   }
   print $FH "17. Kernel Suspend Resume Check - [Not Implemented ]\n";


   system("adb reboot");
   my $ret = `adb wait-for-device | adb logcat | timeout 180s grep -m1 "qdcmApplyDefaultAfterBootAnimationDone"`;
   system("adb logcat -d > logcat.txt");
   open(FILE, "/home/smoke/smoketest/auto-smoke/logcat.txt") or die "Unable to open logcat";
   $_ = <FILE>;
   close(FILE);

   if ($ret =~ m/qdcmApplyDefaultAfterBootAnimationDone/) {
       print $FH "18. Boot Animation Test - PASSED \n";
       $test = "PASSED";
   }
   else {
        print $FH "18. Boot Animation Test - FAILED \n";
        $test = "FAILED";
   }
   $ret = `ruby ./post_request.rb 'admin' '$mypwd'  https://cdtestcentral.innominds.com/api/update_testcase_execution.xml '<request> <project>Indra M Upgrade</project> <execution>algizrt7_userdebug_daily-MPAA1-$buildID</execution> <testcase> <title>[FWGEN_FS_11] Boot Animation</title> <duration>620</duration> <step position="1" result="$test" comment="Result Posted from SmokeTest"></step> </testcase> </request>'`;
   print "$ret\n";
   if($ret =~m/updated/){
    # print "test Object updated for Build Flash\n";
   }
   else{
    print "Unable to update Build Flash test\n";
   }





system("adb wait-for-devices");



my $rebootCommand = "adb reboot recovery";
my $logcatCommand = "timeout 10s adb logcat | grep -i 'recovery'";

# Execute the reboot command
print "Device moving to recovery mode.\n";
system($rebootCommand);
print "device is in recovery mode.\n";
sleep(50);
print "device rebooting.\n";
system("adb reboot");
print "waiting for device.\n";
system("adb wait-for-device");
print "Device available now.\n";

# Wait for the device to reboot
# (Add additional sleep time if required)

# Check if the device has entered recovery mode

my $logcatOutput = qx($logcatCommand);
print "logs captured.\n";
if ($logcatOutput =~ /recovery/i) {
    print "Device successfully entered recovery mode.\n";
    print $FH "ADB reboot recovery Test - PASSED\n";
} else {
    print "Failed to enter recovery mode.\n";
    print $FH "ADB reboot recovery Test - FAILED\n";
}




my $rebootCommand = "adb reboot bootloader";
my $fastbootDevicesCommand = "fastboot devices";
my $logcatCommand = "timeout 10s adb logcat | grep -i 'booting'";

# Execute the reboot command
print "Device rebooting.\n";
system($rebootCommand);

# Wait for the device to reboot
sleep(30);

# Check if the device is connected in fastboot mode
my $fastbootDevicesOutput = qx($fastbootDevicesCommand);
if ($fastbootDevicesOutput =~ /\bfastboot\b/i) {
    print "Device successfully entered fastboot mode.\n";
    system("fastboot devices");
    print $FH "bootloader Test - PASSED\n";
    system("fastboot reboot");
    system("adb wait-for-device");
} else {
    print "Failed to enter bootloader mode.\n";
    print $FH "bootloader Test - FAILED\n";
    #system("fastbbot reboot");
}


sleep(30);
my $ADBDevicesOutput = qx($logcatCommand);
if ($ADBDevicesOutput =~ /\bbooting\b/i) {
    print "Device successfully entered fastboot mode.\n";
    print $FH "Fastboot reboot Test - PASSED\n";
} else {
    print "Failed to enter fastboot mode.\n";
    print $FH "Fastboot reboot Test - FAILED\n";
    #system("fastboot reboot");
}

# Check the logcat output for reboot events
my $logcatOutput = qx($logcatCommand);
print "ADB reboot testing\n";
if ($logcatOutput =~ /\bbooting\b/i) {
    print "Device reboot event detected in logcat.\n";
    print $FH "ADB reboot Test - PASSED\n";
} else {
    print "No reboot event detected in logcat.\n";
    print $FH "ADB reboot Test - FAILED\n";
}

}
