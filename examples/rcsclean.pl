#!/usr/local/bin/perl -w
#------------------------------------------
# rcsclean utility
#------------------------------------------
use Version::Rcs;

Version::Rcs->quiet(0);      # turn off quiet mode
Version::Rcs->bindir("/usr/bin");

$obj = Version::Rcs->new;

print "Quiet mode NOT set\n" unless Version::Rcs->quiet;

$obj->rcsdir("./project_tree/archive");
$obj->workdir("./project_tree/src");
$obj->file("cornholio.pl");

$obj->rcsclean;
