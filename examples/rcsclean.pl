#!/usr/local/bin/perl -w
#------------------------------------------
# rcsclean utility
#------------------------------------------
use Rcs;

Rcs->quiet(0);      # turn off quiet mode
$obj = Rcs->new;

print "Quiet mode NOT set\n" unless Rcs->quiet;

$obj->rcsdir("./project_tree/archive");
$obj->workdir("./project_tree/src");
$obj->file("cornholio.pl");

$obj->rcsclean;
