use strict;
use warnings;

sub btcheck {
    my $lresult;  

    my $output = `adb shell settings get global bluetooth_on`;
    chomp($output);

    if ($output == 1) {
        print "Bluetooth is currently enabled. Disabling...\n";
        `adb shell am start -a android.bluetooth.adapter.action.REQUEST_DISABLE`;

        # Wait for the prompt to appear
        sleep(5);

        # Simulate pressing the Tab key twice
        `adb shell input keyevent 61`;
        `adb shell input keyevent 61`;

        # Simulate pressing the Enter key
        `adb shell input keyevent 66`;

        print "Bluetooth has been disabled.\n";
    } elsif ($output == 0) {
        print "Bluetooth is currently disabled. Enabling...\n";
        `adb shell am start -a android.bluetooth.adapter.action.REQUEST_ENABLE`;

        # Wait for the prompt to appear
        sleep(5);

        # Simulate pressing the Tab key twice
        `adb shell input keyevent 61`;
        `adb shell input keyevent 61`;

        # Simulate pressing the Enter key
        `adb shell input keyevent 66`;

        print "Bluetooth has been enabled.\n";
        $lresult = "PASSED";
    } else {
        print "Unable to determine Bluetooth status.\n";
        $lresult = "FAILED";
    }

    # Ensure Bluetooth is disabled at the end
    sleep(5);
    $output = `adb shell settings get global bluetooth_on`;
    chomp($output);

    if ($output == 1) {
        print "Bluetooth is still enabled. Disabling...\n";
        `adb shell am start -a android.bluetooth.adapter.action.REQUEST_DISABLE`;

        # Wait for the prompt to appear
        sleep(5);

        # Simulate pressing the Tab key twice
        `adb shell input keyevent 61`;
        `adb shell input keyevent 61`;

        # Simulate pressing the Enter key
        `adb shell input keyevent 66`;

        print "Bluetooth has been disabled.\n";
    } elsif ($output == 0) {
        print "Bluetooth is disabled.\n";
        $lresult = "PASSED";
    } else {
        print "Unable to determine Bluetooth status.\n";
        $lresult = "FAILED";
    }
    return $lresult;
}

