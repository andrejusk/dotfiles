#!/usr/bin/env perl
use strict;
use warnings;
use autodie;

use Cwd;
use Stow;


my $dir = getcwd;
my $target = $ENV{'HOME'};
print "Stowing $dir/files to $target\n";

my %stow_options = ( dir => $dir,
	             target => $target);
my $stow = new Stow(%stow_options);

my @pkgs = ('files');
$stow->plan_stow(@pkgs);

$stow->process_tasks();
print "done\n";

