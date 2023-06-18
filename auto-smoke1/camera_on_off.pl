#****************************************************************************************************************************************************
# * Copyright (C) 1998-2016 Connected Devices, Innominds Software Inc.
# *
# * This file is part of Connected Devices Project
# *
# * Connected Devices Project and associated code can not be copied
# * and/or distributed without the express permission of
# * Innominds Software Inc. and/or it subsidiaries
# *
# * Description: This script will provide the camera on/off test case results.
# * For any modification contact @Ramamohan (rbandapalli@innominds.com)
#*****************************************************************************************************************************************************

#!/usr/bin/perl
use strict;
use warnings;
my $lresult;
my $camstatus=0;
sub camera_status
{
   my $status;
   system("adb shell dumpsys media.camera > cam.txt");
   $status = `grep "Device is open"  cam.txt`;
   if($status =~ m/Device is open/)
    {
       print("camera successfully launched \n");
        $camstatus=0;
    }
    elsif($status =~ m/Device is closed/)
    {
       print("unable to launch the camera \n");
       $camstatus=1;
    }
   return $camstatus;
}
sub camera_image_test {
    my $ret = `adb logcat -d`;
    if ($ret =~ m/ActivityManager: Crashing/) {
        system("adb shell input keyevent 23");
        system("adb shell input keyevent 23");
        system("adb shell input keyevent 23");
        system("adb shell input keyevent 23");
    }
    system("adb shell input keyevent 82");
    system("adb shell am start -a android.intent.action.MAIN -c android.intent.category.HOME");
    print("Camera image test case execution starting\n");
    print("Checking the camera status\n");
    system("adb shell rm /sdcard/DCIM/Camera/*");
    system("adb wait-for-device shell input keyevent 3");
    camera_status();
    if ($camstatus == 0) {
        cam_start();
        check_issaved_image();
    } else {
        print "No active camera found on the device\n";
        $lresult = "FAILED";
    }
    return $lresult;
}

sub camera_video_test
{
   system("adb shell input keyevent 82");
   system("adb shell am start -a android.intent.action.MAIN -c android.intent.category.HOME");
   print("camera video test case excution starting \n");
   print("Checking the camera status \n");
   system("adb shell rm /sdcard/DCIM/Camera/*");
   system("adb wait-for-device shell input keyevent 3");
   camera_status();
   if ($camstatus==0)
   {
      cam_video();
      check_issaved_video();
   }
   else{
        print "No active camera found on the device \n";
        $lresult = "FAILED";
   }
   return $lresult;
}
sub cam_start {
   print("Launching the front camera \n");
   system("adb wait-for-device shell input keyevent 3");
   system("adb shell am start -a android.media.action.STILL_IMAGE_CAMERA --ei android.intent.extras.CAMERA_FACING 1 > camera.txt");
   sleep(3);
   system("adb wait-for-device shell input keyevent KEYCODE_CAMERA");
   sleep(1);
   system("adb wait-for-device shell input keyevent KEYCODE_BACK");
   sleep(1);
   system("rm -r cam.txt");
   system("adb shell dumpsys media.camera > cam.txt");
   sleep(1);
   print("Launching the back camera \n");
   system("adb shell am start -a android.intent.action.MAIN -c android.intent.category.HOME > home.txt");
   system("adb wait-for-device shell am start -a android.media.action.STILL_IMAGE_CAMERA --ei android.intent.extras.CAMERA_FACING 0 >  camera.txt");
   sleep(3);
   system("adb wait-for-device shell input keyevent KEYCODE_CAMERA");
   sleep(1);
   system("adb wait-for-device shell input keyevent KEYCODE_BACK");
   sleep(1);
}


sub cam_video{
    print("Launching the camera and capturing the video \n");
    system("adb wait-for-device shell input keyevent 3");
    system("adb shell am start -a android.media.action.VIDEO_CAPTURE");
    system("adb wait-for-device shell input keyevent KEYCODE_CAMERA");
    sleep(10);
    system("adb wait-for-device shell input keyevent KEYCODE_CAMERA");
    system("adb wait-for-device shell input keyevent KEYCODE_BACK");
    system("adb wait-for-device shell input keyevent KEYCODE_BACK");
    system("adb wait-for-device shell input keyevent 3");
    sleep(5);
}

sub check_issaved_image
{
   my $dir = "camera";
   system("adb wait-for-device shell input keyevent 3");
   system("rm -r camera");
   system("mkdir camera");
   system("adb pull /sdcard/DCIM/Camera/ ./camera/");
   opendir DIR, $dir or die "cannot open dir $dir: $!";
   my @files = readdir DIR;
   my @fgrep = grep /.jpg/, @files;
   my @vgrep = grep /.mp4/, @files;
   if (scalar @files!=0){
      if (scalar @fgrep==0)
      {
         print "No camera images found in device\n";
         $lresult = "FAILED";
      }
      else{
         print "Captured images found...\n";
         $lresult = "PASSED";
      }
   }
   else{
         print "No camera images found in device\n";
         $lresult = "FAILED";
   }
   closedir DIR;
   return $lresult;
}

sub check_issaved_video
{
   my $dir = "camera";
   system("adb wait-for-device shell input keyevent 3");
   system("rm -r camera");
   system("mkdir camera");
   system("adb pull /sdcard/DCIM/Camera/ ./camera/");
   opendir DIR, $dir or die "cannot open dir $dir: $!";
   my @files = readdir DIR;
   my @vgrep = grep /.mp4/, @files;
   if (scalar @files!=0){
      if (scalar @vgrep==0)
      {
         print "No videos found in device\n";
         $lresult = "FAILED";
      }
      else{
         print "Captured videos available...\n";
         $lresult = "PASSED";
      }
   }
   else{
         print "No camera images found in device\n";
         $lresult = "FAILED";
   }
   closedir DIR;
   return $lresult;
}
sub audio_test
{
   print "Pushing audio and video to /sdcard";
   my $ret = `adb push ./testAudioMP3.mp3 /sdcard/`;
   $ret = `adb shell am start -a android.intent.action.VIEW -d file:///sdcard/testAudioMP3.mp3 -t audio/mp3`;
   system("adb shell input keyevent 25");
   system("adb shell input keyevent 25");
   system("adb shell input keyevent 25");
   system("adb shell input keyevent 25");
   sleep(10);
   $ret = `adb shell dumpsys media.player | grep -i -e 'state(0)' -e 'state(1)' -e 'state(2)'`;
   #$ret = `adb shell dumpsys | grep "state=PlaybackState"`;
   print $ret;
   if ($ret =~ /\Qstate(0)\E/)
   {
      $lresult = "PASSED";
   }
   else{
      $lresult = "FAILED";
   }
   return  $lresult;
}
sub video_test
{
   system("adb push ./1080P_24fps.m4v /sdcard/Movies/");
   system("adb shell am start -a android.intent.action.VIEW -d file:///sdcard/movies/1080P_24fps.m4v -t video/3gp");
   system("adb shell input keyevent 85");
   sleep(10);
   my $ret = `adb shell dumpsys media.player | grep "numFramesTotal"`;
   print $ret;
   if ($ret)
   {
      $lresult = "PASSED";
   }
   else{
       $lresult = "FAILED";
   }

}
sub camera_image_test {
    my $ret = `adb logcat -d`;
    if ($ret =~ m/ActivityManager: Crashing/) {
        system("adb shell input keyevent 23");
        system("adb shell input keyevent 23");
        system("adb shell input keyevent 23");
        system("adb shell input keyevent 23");
    }
    system("adb shell input keyevent 82");
    system("adb shell am start -a android.intent.action.MAIN -c android.intent.category.HOME");
    print("Camera image test case execution starting\n");
    print("Checking the camera status\n");
    system("adb shell rm /sdcard/DCIM/Camera/*");
    system("adb wait-for-device shell input keyevent 3");
    camera_status();
    if ($camstatus == 0) {
        cam_start();
        check_issaved_image();
    } else {
        print "No active camera found on the device\n";
        $lresult = "FAILED";
    }
    return $lresult;
}

sub camera_video_test
{
   system("adb shell input keyevent 82");
   system("adb shell am start -a android.intent.action.MAIN -c android.intent.category.HOME");
   print("camera video test case excution starting \n");
   print("Checking the camera status \n");
   system("adb shell rm /sdcard/DCIM/Camera/*");
   system("adb wait-for-device shell input keyevent 3");
   camera_status();
   if ($camstatus==0)
   {
      cam_video();
      check_issaved_video();
   }
   else{
        print "No active camera found on the device \n";
        $lresult = "FAILED";
   }
   return $lresult;
}
1;
