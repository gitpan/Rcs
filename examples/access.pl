#!/usr/local/bin/perl -w
#------------------------------------------
# Add users to access list.
#------------------------------------------
use Version::Rcs;

Version::Rcs->bindir("/usr/bin");

$obj = Version::Rcs->new;

$obj->rcsdir("./project_tree/archive");
$obj->workdir("./project_tree/src");
$obj->file("cornholio.pl");

@users = qw(beavis butthead);
$obj->rcs("-a@users");

$filename = $obj->file;
@access_list = $obj->access;
print "Users @access_list are on the access list of $filename\n";
