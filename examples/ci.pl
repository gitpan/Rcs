#!/usr/local/bin/perl -w
#------------------------------------------
# Check-in source file.
#------------------------------------------
use Version::Rcs;

Version::Rcs->quiet(0);  # turn off quiet mode

my $obj = Version::Rcs->new;
$obj->bindir('/usr/bin');

print "Quiet mode set\n" if Version::Rcs->quiet;

$obj->rcsdir("./project_tree/archive");
$obj->workdir("./project_tree/src");
$obj->file("cornholio.pl");

# archive file exists
if (! -e $obj->rcsdir . '/' . $obj->arcfile) {
    print "Initial Check-in\n";
    $obj->ci("-u", "-t-Program Description");
}

# create archive file
else {
    print "Check-in\n";
    $obj->ci("-u", "-mRevision Comment");
}
