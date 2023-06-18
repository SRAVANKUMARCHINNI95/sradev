#!/usr/bin/perl


=pod
adb reboot
adb reboot recovery------->b
adb reboot bootloader----->fastboot
fastboot reboot


  
my $ret = `adb reboot`;
if ($? == 0) {
    # Command was successful
    system("adb wait-for-device");
    system("timeout 5s adb logcat | grep -m1 'shutdown'");
    print "23. ADB reboot Test - PASSED \n";
} else {
    # Command failed
    print  "23. ADB reboot Test - FAILED \n";
}

=cut


=pod
#!/usr/bin/perl

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
    print "ADB reboot recovery Test - PASSED\n";
} else {
    print "Failed to enter recovery mode.\n";
    print "ADB reboot recovery Test - FAILED\n";
}

=cut




#!/usr/bin/perl

my $rebootCommand = "fastboot reboot";
my $fastbootDevicesCommand = "fastboot devices";
my $logcatCommand = "adb logcat | grep -i 'reboot'";

# Execute the reboot command
print "Device rebooting.\n";

system("adb reboot bootloader");
system($rebootCommand);

print "Wait for the device to reboot";
system("adb wait-for-device");
sleep(20);

# Check if the device is connected in fastboot mode
my $fastbootDevicesOutput = qx($fastbootDevicesCommand);
if ($fastbootDevicesOutput =~ /\bfastboot\b/i) {
    print "Device successfully entered fastboot mode.\n";
    print "Fastboot reboot Test - PASSED\n";
} else {
    print "Failed to enter fastboot mode.\n";
    print "Fastboot reboot Test - FAILED\n";
}

# Check if the device has rebooted
my $logcatOutput = qx($logcatCommand);
if ($logcatOutput =~ /reboot/i) {
    print "Device successfully rebooted.\n";
    print "Fastboot reboot Test - PASSED\n";
} else {
    print "Failed to reboot the device.\n";
    print "Fastboot reboot Test - FAILED\n";
}

