#!/usr/bin/env perl
use strict;
use warnings;
use autodie;

use Cwd;
use Stow;


# Stow files
my $dir = getcwd;
my %stow_options = (
	dir => "$dir/files",
	target => "$ENV{'HOME'}"
);
my $stow = new Stow(%stow_options);
my %conflicts = $stow->get_conflicts;
$stow->process_tasks() unless %conflicts; 

