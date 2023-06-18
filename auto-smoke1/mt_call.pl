#****************************************************************************************************************************************************
# * Copyright (C) 1998-2016 Connected Devices, Innominds Software Inc.
# *
# * This file is part of Connected Devices Project
# *
# * Connected Devices Project and associated code can not be copied
# * and/or distributed without the express permission of
# * Innominds Software Inc. and/or it subsidiaries
# *
# * Description: This script executes the MT call test case.
# * For any modification contact @Ramamohan (rbandapalli@innominds.com)
#*****************************************************************************************************************************************************
#use strict;
#use warnings;
my $call_status;
my $TestCaseName='adblogs';
my $i=0;
my $j=0;

sub end_call
{
#system("adb shell input keyevent 85");
    print("\n Ending the call \n");
    system("adb shell input keyevent KEYCODE_ENDCALL");
}

print("============================================================================= \n");
print("Excuting MT call test case  \n");
print("------------------------------------------------------------------------------ \n");
system("adb wait-for-device shell svc power stayon usb");
sleep(2);
system("adb wait-for-device shell input keyevent 82");
system("adb wait-for-device shell input keyevent 3");
print("Waiting to get a MT call \n");
sleep(30);
$call_status=`adb shell dumpsys telephony.registry | grep mCallState`;
#print("call status=$call_status \n");
if($call_status=~m/mCallState=1/)
{
    print("call in progress successfully Connected a MT call\n");
    end_call();
    sleep(10);
    $call_status=`adb shell dumpsys telephony.registry | grep mCallState`;
#print("call status=$call_status \n");
    if($call_status=~m/mCallState=1/)
    {
        print("call in progress unable to end a call \n");
    }
    else
    {
        print("call ended successfully \n");  
        $j=$j+1;    
    }
}
else
{
    print("device is idle, so please intiate a MT call \n");
}

if($j==1)
{
    print(" \n MT call test case result = pass \n \n");
}
else
{
    print(" \n MT call test case result = Fail \n \n");
}
