#!/usr/local/bin/perl -w
#------------------------------------------
# Access comments hash
#------------------------------------------
use strict;
use Rcs;

Rcs->bindir('/usr/bin');
my $obj = Rcs->new;

$obj->rcsdir("./project/RCS");
$obj->workdir("./project/src");
$obj->file("testfile");

my %comments = $obj->comments;
my $revision;
foreach $revision (keys %comments) {
    my $comments = $comments{$revision};
    print "======\n";
    print "Revision: $revision\n";
    print "$comments\n";
}
