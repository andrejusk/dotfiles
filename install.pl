#!/usr/bin/env perl
use strict;
use warnings;

use Cwd;

# Prevent running as root
if ($< == 0) {
    print "Failed: Running as root. Please run as user, not sudo\n";
    exit (1);
}

# Generate unique logfile
my $uuid = `uuidgen`;
chomp $uuid;
my $log_path = "$ENV{'HOME'}/.dotfiles.$uuid.log";
print "Logs: $log_path\n";


my $dir = getcwd;
my $install_dir = "$dir/install";
print "Installing $install_dir\n";

# Read scripts to be installed
opendir(DIR, $install_dir) or die "Could not open $install_dir\n";
my @files = readdir(DIR);
closedir(DIR);
@files = sort { lc($a) cmp lc($b) } @files;

foreach my $file (@files)
{
    # Install all scripts by default
    next if($file !~ /^\d{2}-.*\.sh$/);

    print "Running $file...\r";
    my $exit_status = system("/bin/bash -l $install_dir/$file >> $log_path 2>&1");
    if ($exit_status != 0) {
        print "Failure in $file, see above and logs for more detail.\n";
        exit ($exit_status);
    }
}
