#!/usr/local/bin/perl -w
#------------------------------------------
# Use rcsdiff utility.
#------------------------------------------
use Rcs;

Rcs->quiet(1);

my $obj = Rcs->new;
$obj->bindir('/usr/bin');
print "Quiet mode set\n" if Rcs->quiet;

$obj->rcsdir("./project_tree/archive");
$obj->workdir("./project_tree/src");
$obj->file("cornholio.pl");

print "Diff of current working file\n";
if ($obj->rcsdiff) {       # scalar context
    print $obj->rcsdiff;   # list context
}
else {
   print "Versions are Equal\n";
}

print "\n\nDiff of revisions 1.2 and 1.1\n";
print $obj->rcsdiff('-r1.2', '-r1.1');
