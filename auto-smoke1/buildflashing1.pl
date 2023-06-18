#****************************************************************************************************************************************************
# * Copyright (C) 1998-2016 Connected Devices, Innominds Software Inc.
# *
# * This file is part of Connected Devices Project
# *
# * Connected Devices Project and associated code can not be copied
# * and/or distributed without the express permission of
# * Innominds Software Inc. and/or it subsidiaries
# *
# * Description: This script loads the build images into the target
# * For any modification contact @Ramamohan (rbandapalli@innominds.com)
#*****************************************************************************************************************************************************

#!/usr/bin/perl

my $lresult = "FAILED";
my $find;
sub buildflashing
{
   system("adb devices");
   my $build_path = "/home/sravankumarchinni/Desktop/Androidkernel/Builds/DBG_LA1.0_Landscape";
   print "Build loading from $build_path \n";
   print "File paths:";
   print "$build_path/boot.img\n";
   print "$build_path/dtbo.img\n";
   print "$build_path/metadata.img\n";
   my $retValue;
 
   {
      print "**************************moving device to fatboot**************************\n";
      $retValue = `adb wait-for-device reboot bootloader`;
      system("fastboot devices");
      print "**************************boot.img**************************\n";
      $retValue = `fastboot --slot all flash boot $build_path/boot.img`;
      if ($retValue)
      {
         print ("Unable to flash boot image\n");
         exit();
      }
      print "**************************dtbo.img**************************\n";
      $retValue = `fastboot flash boot dtbo_a $build_path/dtbo.img`;
      if ($retValue)
      {
         print ("Unable to flash boot dtbo_a dtbo.img\n");
         exit();
      }
      $retValue = `fastboot flash dtbo_b $build_path/dtbo.img`;
      if ($retValue)
      {
         print ("Unable to flash system dtbo_b dtboimage\n");
         exit();
      }
      print "**************************metadata.img**************************\n"; 
      $retValue = `fastboot flash metadata $build_path/metadata.img`;
      if ($retValue)
      {
         print ("Unable to flash metadata image\n");
         exit();
      }
      print "**************************recovery.img**************************\n";
      $retValue = `fastboot flash recovery_a $build_path/recovery.img`;
      if ($retValue)
      {
         print ("Unable to flash recovery_a recovery image\n");
         exit();
      } 
      $retValue = `fastboot flash recovery_b $build_path/recovery.img`;
      if ($retValue)
      {
         print ("Unable to flash recovery_b recovery image\n");
         exit();
      } 
      print "**************************super.img**************************\n";
      $retValue = `fastboot flash super $build_path/super.img`;
      if ($retValue)
      {
         print ("Unable to flash metadata image\n");
         exit();
      } 
      print "**************************vbmeta.img**************************\n";
      $retValue = `fastboot flash vbmeta_a $build_path/vbmeta.img`;
      if ($retValue)
      {
         print ("Unable to flash metadata image\n");
         exit();
      } 
      $retValue = `fastboot flash vbmeta_b $build_path/vbmeta.img`;
      if ($retValue)
      {
         print ("Unable to flash metadata image\n");
         exit();
      } 
      print "**************************vbmeta_system.img**************************\n";
      $retValue = `fastboot flash vbmeta_system_a  $build_path/vbmeta_system.img`;
      if ($retValue)
      {
         print ("Unable to flash vbmeta_system_a vbmeta_system.image\n");
         exit();
      } 
      $retValue = `fastboot flash vbmeta_system_b  $build_path/vbmeta_system.img`;
      if ($retValue)
      {
         print ("Unable to flash vbmeta_system_b vbmeta_system.image\n");
         exit();
      } 
      print "************************************************ userdata.img **********************************\n";
      $retValue = `fastboot flash userdata  $build_path/userdata.img`;
      if ($retValue)
      {
         print ("Unable to flash userdata userdata.image\n");
         exit();
      } 
      
      print "************************************************ Current slot of the device **********************************\n";
      system("fastboot getvar current-slot");
      print "************************************************ Set the device slot to a**********************************\n";
      system("fastboot set_active a");
      print "************************************************ rebooting**********************************\n";
      system("adb reboot");
      print "************************************************ Build flashing completed **********************************\n";
      system("adb wait-for-device devices");
      my $time1 = `date | cut -d ' ' -f4`;
      my $ret = `adb logcat | grep -m1 "BOOT_COMPLETED"`;
      print  $ret;
      if ($ret=~m/BOOT_COMPLETED/){
                  $lresult = "PASSED";
                 return $lresult;
      }
    }
   return $lresult;
}
1;
buildflashing();
