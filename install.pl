#!/usr/bin/env perl
use strict;
use warnings;
use autodie;

use Cwd;

# Prevent running as root
if ($< == 0) {
    print "Failed: Running as root. Please run as user, not sudo\n";
    exit (1);
}

my $dir = getcwd;

# Generate unique logfile
my $uuid = `uuidgen`;
chomp $uuid;
my $log_path = "$dir/.install.$uuid.log";
print "Logs: $log_path\n";

# Ensure dependencies installed
`sudo apt-get update -y && sudo apt-get install -y liblocal-lib-perl cpanminus stow >> $log_path 2>&1`;

# Bootstrap files
my $exit_status = `./bootstrap.pl >> $log_path 2>&1`;
print $exit_status;

# Read scripts to be installed
my $install_dir = "$dir/install";
print "Installing $install_dir\n";
opendir(DIR, $install_dir) or die "Could not open $install_dir\n";
my @files = readdir(DIR);
closedir(DIR);
@files = grep(/^\d{2}-.*\.sh$/, @files);
@files = sort { lc($a) cmp lc($b) } @files;

# Install selected targets
my $target = $ENV{'TARGET'} // 'all';
if ($target ne 'all') {
    @files = grep(/${target}/, @files);
}
foreach my $file (@files) {
    print "Running $file...\r";
    my $exit_status = system("/bin/bash -l $install_dir/$file >> $log_path 2>&1");
    if ($exit_status != 0) {
        print "Failure in $file, see above and logs for more detail.\n";
        exit ($exit_status);
    }
}
