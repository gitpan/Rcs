#!/usr/local/bin/perl -w
#------------------------------------------
# Check-out source file.
#------------------------------------------
use Version::Rcs;

Version::Rcs->quiet(0);  # turn off quiet mode

my $obj = Version::Rcs->new;
$obj->bindir('/usr/bin');

print "Quiet mode set\n" if Version::Rcs->quiet;

$obj->rcsdir("./project_tree/archive");
$obj->workdir("./project_tree/src");
$obj->file("cornholio.pl");

$obj->co('-l');
