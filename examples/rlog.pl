#!/usr/local/bin/perl -w
#------------------------------------------
# Use rlog utility.
#------------------------------------------
use Version::Rcs;

Version::Rcs->quiet(1);

my $obj = Version::Rcs->new;
$obj->bindir('/usr/bin');

print "Quiet mode set\n" if Version::Rcs->quiet;

$obj->rcsdir("./project_tree/archive");
$obj->workdir("./project_tree/src");
$obj->file("cornholio.pl");

print $obj->rlog;
