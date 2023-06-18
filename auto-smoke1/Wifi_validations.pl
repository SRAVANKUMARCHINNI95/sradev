use strict;
use warnings;

sub get_wifi_interfaces {
    my @interfaces;
    
    open(my $ifconfig_fh, "-|", "ifconfig -a") or die "Failed to execute command: ifconfig -a";
    
    while (my $line = <$ifconfig_fh>) {
        if ($line =~ /^(\w+)\s+.*\bUP\b.*\bRUNNING\b.*\bMULTICAST\b.*\bWIRELESS\b/i) {
            push @interfaces, $1;
        }
    }
    
    close($ifconfig_fh);
    
    return @interfaces;
}

# Usage:
my @wifi_interfaces = get_wifi_interfaces();

if (@wifi_interfaces) {
    print "Available Wi-Fi interfaces: @wifi_interfaces\n";
} else {
    print "No Wi-Fi interfaces found.\n";
}

