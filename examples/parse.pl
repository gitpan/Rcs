#!/usr/local/bin/perl
#------------------------------------------
# Parse RCS archive file.
#------------------------------------------
use Version::Rcs;

$obj = Rcs->new;

$obj->rcsdir("./project_tree/archive");
$obj->workdir("./project_tree/src");
$obj->file("cornholio.pl");

$head_rev = $obj->head;
$locker = $obj->lock;
$author = $obj->author;
@access = $obj->access;
@revisions = $obj->revisions;

$filename = $obj->file;

if ($locker) {
    print "Head revision $head_rev is locked by $locker\n";
}
else {
    print "Head revision $head_rev is unlocked\n";
}

if (@access) {
    print "\nThe following users are on the access list of file $filename\n";
    map { print "User: $_\n"} @access;
}

print "\nList of all revisions of $filename\n";
foreach $rev (@revisions) {
    print "Revision: $rev\n";
}
