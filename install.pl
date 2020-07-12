#!/usr/bin/env perl
use strict;
use warnings;
use autodie;

use File::Basename;

# Prevent running as root
if ($< == 0) {
    print "Failed: Running as root. Please run as user, not sudo\n";
    exit (1);
}

my $dir = dirname(__FILE__);

my $log_target = $ENV{'LOG_TARGET'} // '';
my $log_path = '';
if ($log_target ne 'STDOUT') {
    # Generate unique logfile
    my $log_dir = "$dir/logs";
    `mkdir -p $log_dir`;
    my $uuid = `uuidgen`;
    chomp $uuid;
    $log_path = "$log_dir/$uuid.log";
    print "Logs: $log_target\n";
}

# Execute given command and log appropriately
# @arg 0 command to run
sub log_execute {
    my $command = $log_path ne ''
                   ? "$_[0] &> $log_path"
                   : $_[0];
    print "# $command\n";
    return system($command);
}


# Ensure dependencies installed
log_execute("sudo apt-get update -qqy && sudo apt-get install -qqy build-essential liblocal-lib-perl cpanminus stow");

# Bootstrap files
log_execute("make -C $dir");

# Read scripts to be installed
my $install_dir = "$dir/install";
print "Installing $install_dir\n";
opendir($dir, $install_dir) or die "Could not open $install_dir\n";
my @files = readdir($dir);
closedir($dir);
@files = grep(/^\d{2}-.*\.sh$/, @files);
@files = sort { lc($a) cmp lc($b) } @files;

# Install selected targets
my $target = $ENV{'TARGET'} // 'all';
if ($target ne 'all') {
    @files = grep(/${target}/, @files);
}
foreach my $file (@files) {
    print "Running $file...\r";
    my $exit_status =  log_execute("/bin/bash -l $install_dir/$file");
    if ($exit_status != 0) {
        print "Failure in $file, see above and logs for more detail.\n";
        exit ($exit_status);
    }
}
