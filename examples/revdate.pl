#!/usr/local/bin/perl -w
#------------------------------------------
# Add users to access list.
#------------------------------------------
use Rcs;

$obj = Rcs->new;

$obj->rcsdir("./project/RCS");
$obj->workdir("./project/src");
$obj->file("testfile");

# scalar mode
$scalar_date = $obj->revdate;
print "Scalar date = $scalar_date\n";
$date_str = localtime($scalar_date);
print "Scalar date string = $date_str\n";

# list mode
@list_date = $obj->revdate;
print "List date = @list_date\n";

