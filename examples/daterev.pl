#!/usr/local/bin/perl -w
#------------------------------------------
# Test daterev method
#------------------------------------------
use strict;
use Rcs;

#Rcs->bindir('/usr/bin');
my $obj = Rcs->new;

$obj->rcsdir("./project/RCS");
$obj->workdir("./project/src");
$obj->file("testfile");

my @date_array = @ARGV;

# scalar mode
my $revision = $obj->daterev(@date_array);
my $date_str = gmtime($obj->revdate($revision));
print "Date : Revision = $date_str : $revision\n\n";


# list mode
print "List mode\n";
my @revisions = $obj->daterev(@date_array);
foreach (@revisions) {
    $date_str = gmtime($obj->revdate($_));
    print "Date : Revision = $date_str : $_\n";
}
