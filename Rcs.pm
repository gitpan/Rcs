package Version::Rcs;
require 5.001;
use strict;
use Carp;
use vars qw($VERSION $revision);

#------------------------------------------------------------------
# global stuff
#------------------------------------------------------------------
$VERSION = '0.01';
$revision = '$Id: Rcs.pm,v 1.5 1998/01/10 03:09:43 freter Exp freter $';
my $Rcs_Bin_Dir = '/usr/local/bin';
my $Quiet = 1;    # RCS quiet mode

#------------------------------------------------------------------
# RCS object constructor
#------------------------------------------------------------------
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};

    # provide default values for system stuff
    $self->{RCSDIR}     = './RCS';
    $self->{WORKDIR}    = '.';
    $self->{"_BINDIR"}  = \$Rcs_Bin_Dir;
    $self->{"_QUIET"}   = \$Quiet;

    $self->{FILE}       = undef;
    $self->{ARCFILE}    = undef;
    $self->{AUTHOR}     = undef;
    $self->{LOCK}       = undef;
    $self->{ACCESS}     = [];
    $self->{REVISIONS}  = [];
    $self->{REVINFO}    = {};
    $self->{STATE}      = {};
    $self->{SYMBOLS}    = {};
    bless($self, $class);
    return $self;
}

#------------------------------------------------------------------
# access
# Access list of archive file.
#------------------------------------------------------------------
sub access {
    my $self = shift;

    if (not @{ $self->{ACCESS} }) {
        _parse_rcs($self);
    }

    # dereference revisions list
    my @access = @{ $self->{ACCESS} };

    return @access;
}

#------------------------------------------------------------------
# arcfile
# Name of RCS archive file.
# If not set then return name of working file with ',v' RCS
# extension.
#------------------------------------------------------------------
sub arcfile {
    my $self = shift;
    if (@_) { $self->{ARCFILE} = shift }
    return $self->{ARCFILE} || $self->{FILE} . ',v';
}

#------------------------------------------------------------------
# author
# Return the author of an RCS revision.
# If revision is not provided, default to 'head' revision.
#------------------------------------------------------------------
sub author {
    my $self = shift;

    if (not defined $self->{AUTHOR}) {
        _parse_rcs($self);
    }
    my $revision = shift || $self->{HEAD};

    # dereference author hash
    my %author_array = %{ $self->{AUTHOR} };

    return $author_array{$revision};
}

#------------------------------------------------------------------
# bindir
# Set the bin directory in which the RCS distribution programs
# reside.
#------------------------------------------------------------------
sub bindir {
    my $self = shift;

    # called as object method
    if (ref $self) {

        # set bin dir
        if (@_) {
            ${ $self->{"_BINDIR"} } = shift;
            return ${ $self->{"_BINDIR"} };
        }

        # access bin dir
        else {
            return ${ $self->{"_BINDIR"} };
        }
    }

    # called as class method
    else {

        # set bin dir
        if (@_) {
            $Rcs_Bin_Dir = shift;
            return $Rcs_Bin_Dir;
        }

        # access bin dir
        else {
            return $Rcs_Bin_Dir;
        }
    }
}

#------------------------------------------------------------------
# ci
# Execute RCS 'ci' program.
# Make archive filename same as working filename unless
# specifically set.
#------------------------------------------------------------------
sub ci {
    my $self = shift;
    my @param = @_;

    my $ciprog = ${ $self->{"_BINDIR"} } . '/' . 'ci';
    my $rcsdir = $self->{RCSDIR};
    my $workdir = $self->{WORKDIR};
    my $file = $self->{FILE};
    my $arcfile = $self->{ARCFILE} || $file;

    my $archive_file = $rcsdir . '/' . $arcfile . ',v';
    my $workfile = $workdir . '/' . $file;
    push @param, $archive_file, $workfile;
    unshift @param, "-q" if ${ $self->{"_QUIET"} };     # quiet mode

    # run program
    croak "ci program $ciprog not found" unless -e $ciprog;
    croak "ci program $ciprog not executable" unless -x $ciprog;
    system($ciprog, @param) == 0 or croak "$!";

    # re-parse RCS file
    _parse_rcs($self);
}

#------------------------------------------------------------------
# co
# Execute RCS 'co' program.
# Make archive filename same as working filename unless
# specifically set.
#------------------------------------------------------------------
sub co {
    my $self = shift;
    my @param = @_;

    my $coprog = ${ $self->{"_BINDIR"} } . '/' . 'co';
    my $rcsdir = $self->{RCSDIR};
    my $workdir = $self->{WORKDIR};
    my $file = $self->{FILE};
    my $arcfile = $self->{ARCFILE} || $file;

    my $archive_file = $rcsdir . '/' . $arcfile . ',v';
    my $workfile = $workdir . '/' . $file;
    push @param, $archive_file, $workfile;
    unshift @param, "-q" if ${ $self->{"_QUIET"} };     # quiet mode

    # run program
    croak "co program $coprog not found" unless -e $coprog;
    croak "co program $coprog not executable" unless -x $coprog;
    system($coprog, @param) == 0 or croak "$!";

    # re-parse RCS file
    _parse_rcs($self);
}

#------------------------------------------------------------------
# file
# Name of working file.
#------------------------------------------------------------------
sub file {
    my $self = shift;
    if (@_) { $self->{FILE} = shift }
    return $self->{FILE};
}

#------------------------------------------------------------------
# head
# Return the head revision.
#------------------------------------------------------------------
sub head {
    my $self = shift;

    if (not defined $self->{HEAD}) {
        _parse_rcs($self);
    }
    return $self->{HEAD};
}

#------------------------------------------------------------------
# lock
#------------------------------------------------------------------
sub lock {
    my $self = shift;

    if (not defined $self->{LOCK}) {
        _parse_rcs($self);
    }
    return $self->{LOCK};
}

#------------------------------------------------------------------
# quiet
# Set or un-set RCS quiet mode.
#------------------------------------------------------------------
sub quiet {
    my $self = shift;

    # called as object method
    if (ref $self) {

        # set/un-set quiet mode
        if (@_) {
            my $mode = shift;
            croak "Passed parameter must be either '0' or '1'"
                unless $mode == 0 or $mode == 1;
            ${ $self->{"_QUIET"} } = $mode;
            return ${ $self->{"_QUIET"} };
        }

        # access quiet mode
        else {
            return ${ $self->{"_QUIET"} };
        }
    }

    # called as class method
    else {

        # set/un-set quiet mode
        if (@_) {
            my $mode = shift;
            croak "Passed parameter must be either '0' or '1'"
                unless $mode == 0 or $mode == 1;
            $Quiet = $mode;
            return $Quiet;
        }

        # access quiet mode
        else {
            return $Quiet;
        }
    }
}

#------------------------------------------------------------------
# rcs
# Execute RCS 'rcs' program.
# Make archive filename same as working filename unless
# specifically set.
#------------------------------------------------------------------
sub rcs {
    my $self = shift;
    my @param = @_;

    my $rcsprog = ${ $self->{"_BINDIR"} } . '/' . 'rcs';
    my $rcsdir = $self->{RCSDIR};
    my $workdir = $self->{WORKDIR};
    my $file = $self->{FILE};
    my $arcfile = $self->{ARCFILE} || $file;

    my $archive_file = $rcsdir . '/' . $arcfile . ',v';
    my $workfile = $workdir . '/' . $file;
    push @param, $archive_file, $workfile;
    unshift @param, "-q" if ${ $self->{"_QUIET"} };     # quiet mode

    # run program
    croak "rcs program $rcsprog not found" unless -e $rcsprog;
    croak "rcs program $rcsprog not executable" unless -x $rcsprog;
    system($rcsprog, @param) == 0 or croak "$?";

    # re-parse RCS file
    _parse_rcs($self);
}

#------------------------------------------------------------------
# rcsclean
# Execute RCS 'rcsclean' program.
#------------------------------------------------------------------
sub rcsclean {
    my $self = shift;
    my @param = @_;

    my $rcscleanprog = ${ $self->{"_BINDIR"} } . '/' . 'rcsclean';
    my $rcsdir = $self->{RCSDIR};
    my $workdir = $self->{WORKDIR};
    my $file = $self->{FILE};
    my $arcfile = $self->{ARCFILE} || $file;

    my $archive_file = $rcsdir . '/' . $arcfile . ',v';
    my $workfile = $workdir . '/' . $file;
    push @param, $archive_file, $workfile;

    # run program
    croak "rcsclean program $rcscleanprog not found" unless -e $rcscleanprog;
    croak "rcsclean program $rcscleanprog not executable" unless -x $rcscleanprog;
    system($rcscleanprog, @param) == 0 or croak "$?";

    # re-parse RCS file
    _parse_rcs($self);
}

#------------------------------------------------------------------
# rcsdiff
# Execute RCS 'rcsdiff' program.
# Calling in list context returns the output of rcsdiff, while
# calling in scalar context returns the return status of the
# rcsdiff program.
#------------------------------------------------------------------
sub rcsdiff {
    my $self = shift;
    my @param = @_;

    my $rcsdiff_prog = ${ $self->{"_BINDIR"} } . '/' . 'rcsdiff';
    my $rcsdir = $self->{RCSDIR};
    my $arcfile = $self->{ARCFILE} || $self->{FILE};
    $arcfile = $rcsdir . '/' . $arcfile . ',v';
    my $workfile = $self->workdir . '/' . $self->file;

    # un-taint parameter string
    unshift @param, "-q" if ${ $self->{"_QUIET"} };     # quiet mode
    my $param_str = join(' ', @param);
    $param_str =~ s/([\w-]+)/$1/g;

    croak "rcsdiff program $rcsdiff_prog not found" unless -e $rcsdiff_prog;
    croak "rcsdiff program $rcsdiff_prog not executable" unless -x $rcsdiff_prog;
    open(DIFF, "$rcsdiff_prog $param_str $arcfile $workfile |");
    my @diff_output = <DIFF>;

    # rcsdiff returns exit status 0 for no differences, 1 for differences,
    # and 2 for error condition.
    close DIFF;
    my $status = $?;
    croak "$rcsdiff_prog failed" if $status == 2;
    return wantarray ? @diff_output : $status;
}

#------------------------------------------------------------------
# rcsdir
# Location of 'RCS' archive directory.
#------------------------------------------------------------------
sub rcsdir {
    my $self = shift;
    if (@_) { $self->{RCSDIR} = shift }
    return $self->{RCSDIR};
}

#------------------------------------------------------------------
# revisions
#------------------------------------------------------------------
sub revisions {
    my $self = shift;

    if (not @{ $self->{REVISIONS} }) {
        _parse_rcs($self);
    }

    # dereference revisions list
    my @revisions = @{ $self->{REVISIONS} };

    @revisions;
}

#------------------------------------------------------------------
# rlog
# Execute RCS 'rlog' program.
# Make archive filename same as working filename unless
# specifically set.
#------------------------------------------------------------------
sub rlog {
    my $self = shift;
    my @param = @_;

    my $rlogprog = ${ $self->{"_BINDIR"} } . '/' . 'rlog';
    my $rcsdir = $self->{RCSDIR};
    my $arcfile = $self->{ARCFILE} || $self->{FILE};

    # un-taint parameter string
    my $param_str = join(' ', @param);
    $param_str =~ s/([\w-]+)/$1/g;

    my $archive_file = $rcsdir . '/' . $arcfile . ',v';
    croak "rlog program $rlogprog not found" unless -e $rlogprog;
    croak "rlog program $rlogprog not executable" unless -x $rlogprog;
    open(RLOG, "$rlogprog $param_str $archive_file |");

    my @logoutput = <RLOG>;
    close RLOG;
    croak "$rlogprog failed" if $?;
    @logoutput;
}

#------------------------------------------------------------------
# state
# If revision is not provided, default to 'head' revision
#------------------------------------------------------------------
sub state {
    my $self = shift;

    if (not defined $self->{STATE}) {
        _parse_rcs($self);
    }
    my $revision = shift || $self->{HEAD};

    # dereference author hash
    my %state_array = %{ $self->{STATE} };

    return $state_array{$revision};
}

#------------------------------------------------------------------
# symbol
# If revision is not provided, default to 'head' revision
#------------------------------------------------------------------
sub symbol {
    my $self = shift;

    if (not defined $self->{SYMBOLS}) {
        _parse_rcs($self);
    }
    my $revision = shift || $self->{HEAD};

    # dereference symbols hash
    my %sym_array = %{ $self->{SYMBOLS} };

    return '' if not defined $sym_array{$revision};

    my @symbols = @{ $sym_array{$revision} };

    # return only first array element if user wants scalar
    return wantarray ? @symbols : $symbols[0];
}

#------------------------------------------------------------------
# workdir
# Location of working directory.
#------------------------------------------------------------------
sub workdir {
    my $self = shift;
    if (@_) { $self->{WORKDIR} = shift }
    return $self->{WORKDIR};
}

#------------------------------------------------------------------
# _parse_rcs
# Private function
# Directly parse the RCS archive file.
#------------------------------------------------------------------
sub _parse_rcs {

    my $self = shift;
    local $_;

    my ($head, $lock);
    my (@access_list, @revisions);
    my (%author, %state, %symbols);

    my $rcsdir = $self->{RCSDIR};
    my $file = $self->{FILE};

    # parse RCS archive file
    open RCS_FILE, "$rcsdir/$file,v"
        or croak "Unable to open $rcsdir/$file,v";
    while (<RCS_FILE>) {
        next if /^\s*$/;    # skip blank lines
        last if /^desc$/;   # end of header info

        # get head revision
        if (/^head\s/) {
            ($head) = /^head\s+(.*?);$/;
            next;
        }

        # get access list
        if (/^access$/) {
            while (<RCS_FILE>) {
                chomp;
                s/\s//g;        # remove all whitespace
                push @access_list, (split(/;/))[0];
                last if /;$/;
            }
            next;
        }

        # get locker
        # get symbols
        if (/^symbols$/) {
            while (<RCS_FILE>) {
                chomp;
                s/\s//g;        # remove all whitespace
                my ($sym, $rev) = split(/:/);
                $rev =~ s/;$//;
                push @{ $symbols{$rev} }, $sym;
                last if /;$/;
            }
            next;
        }

        # get locker
        if (/^locks/) {

            # file not locked
            if (/strict/) {
                $lock = '';
                next;
            }

            # get user who has file locked
            my $next_line = <RCS_FILE>;    # read next line
            ($lock) = $next_line =~ m/^\s*(\w+):/;
            next;
        }

        # get all revisions
        if (/^\d+\.\d+/) {
            chomp;
            push @revisions, $_;

            # get author and state of each revision
            my $next_line = <RCS_FILE>;
            chop(my $author = (split(/\s+/, $next_line))[3]);
            chop(my $state  = (split(/\s+/, $next_line))[5]);
            $author{$_} = $author;
            $state{$_} = $state;
        }
    }
    close RCS_FILE;

    $self->{HEAD}        = $head;
    $self->{LOCK}        = $lock;
    $self->{ACCESS}      = \@access_list;
    $self->{REVISIONS}   = \@revisions;
    $self->{AUTHOR}      = \%author;
    $self->{STATE}       = \%state;
    $self->{SYMBOLS}     = \%symbols;
}

1;

__END__

=head1 NAME

Rcs - Perl Class for Revision Control System (RCS).

=head1 SYNOPSIS

    use Version::Rcs;

=head1 DESCRIPTION

This Perl module provides an object oriented interface to access 
B<Revision Control System (RCS)> utilities.  RCS must be installed on
the system prior to using this module.  This module should simplify
the creation of an RCS front-end.

=head2 OBJECT CONSTRUCTOR

The B<new> method may be used as either a class method or an object
method to create a new object.

    # called as class method
    $obj = Rcs->new;

    # called as object method
    $newobj = $obj->new;

=head2 CLASS METHODS

Besides the object constructor, there are two class methods provided
which effect any newly created objects.

The B<bindir> method sets the directory path where the RCS executables
(i.e. rcs, ci, co) are located.  The default location is '/usr/local/bin'.

    # set RCS bin directory
    Rcs->bindir('/usr/bin');

    # access RCS bin directory
    $bin_dir = Rcs->bindir;

The B<quiet> method sets/unsets the quiet mode for the RCS executables.
Quiet mode is set bt default.

    # set/unset RCS quiet mode
    Rcs->quiet(0);      # unset quiet mode
    Rcs->quiet(1);      # set quiet mode

    # access RCS quiet mode
    $quiet_mode = Rcs->quiet;

These methods may also be called as object methods.

    $obj->bindir('/usr/bin');
    $obj->quiet(0);

=head2 OBJECT ATTRIBUTE METHODS

These methods set the attributes of the RCS object.

The B<file> method is used to set the name of the RCS working file.  The
filename must be set before invoking any access of modifier methods on the
object.

    $obj->file('mr_anderson.pl');

The B<arcfile> method is used to set the name of the RCS archive file.
Using this method is optional, as the other methods will assume the archive
filename is the same as the working file unless specified otherwise.  The
',v' RCS archive extension is automatically added to the filename.

    $obj->arcfile('principle_mcvicker.pl');

The B<workdir> methods set the path of the RCS working directory.  If not
specified, default path is '.' (current working directory).

    $obj->workdir('/usr/local/source');

The B<rcsdir> methods set the path of the RCS archive directory.  If not
specified, default path is './RCS'.

    $obj->rcsdir('/usr/local/archive');

=head2 RCS PARSE METHODS

This class provides methods to directly parse the RCS archive file.

The B<access> method returns a list of all user on the access list.

    @access_list = $obj->access;

The B<author> method returns the author of the revision.  The head revision
is used if no revision argument is passed to method.

    # returns the author of revision '1.3'
    $author = $obj->author('1.3');

    # returns the authos of the head revision
    $author = $obj->author;

The B<head> method returns the head revision.

    $head = $obj->head;

The B<lock> method returns the locker of the revision.  The method returns
null if the revision is unlocked.  The head revision is used if no revision
argument is passed to method.

    # returns locker of revision '1.3'
    $locker = $obj->lock('1.3');

    # returns locker of head revision
    $locker = $obj->lock;

The B<revisions> method returns a list of all revisions of archive file.

    @revisions = $obj->revisions;

The B<state> method returns the state of the revision. The head revision
is used if no revision argument is passed to method.

    # returns state of revision '1.3'
    $state = $obj->state('1.3');

    # returns state of head revision
    $state = $obj->state;

The B<sysbol> method returns the sysbol(s) associated with a revision.
If called in list context, method returns all symbols associated with
revision.  If called in scalar context, method returns last symbol
assciated with revision.  The head revision is used if no revision argument
is passed to method.

    # list context, returns all symbols associated with revision 1.3
    @symbols = $obj->symbol('1.3');

    # list context, returns all symbols associated with head revision
    @symbols = $obj->symbol;

    # scalar context, returns last symbol associated with revision 1.3
    $symbol = $obj->symbol('1.3');

    # scalar context, returns last symbol associated with head revision
    $symbol = $obj->symbol;

=head2 RCS SYSTEM METHODS

These methods invoke the RCS system utilities.

The B<ci> method calls the RCS ci program.

    # check in, and then check out in unlocked state
    $obj->ci('-u');

The B<co> method calls the RCS co program.

    # check out in locked state
    $obj->co('-l');

The B<rcs> method calls the RCS rcs program.

    # lock file
    $obj->rcs('-l');

The B<rcsdiff> method calls the RCS rcsdiff program.  When called in
list context, this method returns the outpout of the rcsdiff program.
When called in scalar context, this method returns the return status of
the rcsdiff program.  The return status is 0 for the same, 1 for some
differences, and 2 for error condition.

When called without parameters, rcsdiff does a diff between the current
working file, and the last revision checked in.

    # call in list context
    @diff_output = $obj->rcsdiff;

    # call in scalar context
    $changed = $obj->rcsdiff;
    if ($changed) {
        print "Working file has changed\n";
    }

Call rcsdiff with parameters to do a diff between any two revisions.

    @diff_output = $obj->rcsdiff('-r1.2', '-r1.1');

The B<rlog> method calls the RCS rlog program.  This method returns the
output of the rlog program.

    # get complete log output
    @rlog_complete = $obj->rlog;

    # called with '-h' switch outputs only header information
    @rlog_header = $obj->rlog('-h');
    print @rlog_header;

The B<rcsclean> method calls the RCS rcsclean program.

    # remove working file
    $obj->rcsclean;


=head1 EXAMPLES

=head2 CREATE ACCESS LIST

Using method B<rcs> with the CB<-a> switch allows you to add users to
the access list of an RCS archive file.

    use Version::Rcs;
    $obj = Rcs->new;

    $obj->rcsdir("./project_tree/archive");
    $obj->workdir("./project_tree/src");
    $obj->file("cornholio.pl");

Methos B<rcs> invokes the RCS utility rcs with the same parameters.

    @users = qw(beavis butthead);
    $obj->rcs("-a@users");

Calling method B<access> returns list of users on access list.

    $filename = $obj->file;
    @access_list = $obj->access;
    print "Users @access_list are on the access list of $filename\n";


=head2 PARSE RCS ARCHIVE FILE

Set class variables and create 'RCS' object.
Set bin directory where RCS programs (e.g. rcs, ci, co) reside.  The
default is '/usr/local/bin'.  This sets the bin directory for all objects.

    use Version::Rcs;
    Rcs->bindir('/usr/bin');
    $obj = Rcs->new;

Set information regarding RCS object.  This information includes name of the
working file, directory of working file ('.' by default), and RCS archive
directory ('./RCS' by default).

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

=head2 CHECK-IN FILE

Set class variables and create 'RCS' object.
Set bin directory where RCS programs (e.g. rcs, ci, co) reside.  The
default is '/usr/local/bin'.  This sets the bin directory for all objects.

    use Version::Rcs;
    Rcs->bindir('/usr/bin');
    Rcs->quiet(0);      # turn off quiet mode
    $obj = Rcs->new;

Set information regarding RCS object.  This information includes name of
working file, directory of working file ('.' by default), and RCS archive
directory ('./RCS' by default).

    $obj->file('cornholio.pl');

    # Set RCS archive directory, is './RCS' by default
    $obj->rcsdir("./project_tree/archive");

    # Set working directory, is '.' by default
    $obj->workdir("./project_tree/src");

Check in file using CB<-u> switch.  This will check in the file, and will then
check out the file in an unlocked state.  The CB<-m> switch is used to set the
revision comment.

Command:

    $obj->ci('-u', '-mRevision Comment');

is equivalent to commands:

    $obj->ci('-mRevision Comment');
    $obj->co;

=head2 CHECK-OUT FILE

Set class variables and create 'RCS' object.
Set bin directory where RCS programs (e.g. rcs, ci, co) reside.  The
default is '/usr/local/bin'.  This sets the bin directory for all objects.

    use Version::Rcs;
    Rcs->bindir('/usr/bin');
    Rcs->quiet(0);      # turn off quiet mode
    $obj = Rcs->new;

Set information regarding RCS object.  This information includes name of
working file, directory of working file ('.' by default), and RCS archive
directory ('./RCS' by default).

    $obj->file('cornholio.pl');

    # Set RCS archive directory, is './RCS' by default
    $obj->rcsdir("./project_tree/archive");

    # Set working directory, is '.' by default
    $obj->workdir("./project_tree/src");

Check out file read-only:

    $obj->co;

or check out and lock file:

    $obj->co('-l');

=head2 RCSDIFF

Method B<rcsdiff> does an diff between revisions.

    $obj = Rcs->new;
    $obj->bindir('/usr/bin');

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

=head2 RCSCLEAN

Method B<rcsclean> will remove an unlocked working file.

    use Version::Rcs;
    Rcs->bindir('/usr/bin');
    Rcs->quiet(0);      # turn off quiet mode
    $obj = Rcs->new;

    $obj->rcsdir("./project_tree/archive");
    $obj->workdir("./project_tree/src");
    $obj->file("cornholio.pl");

    print "Quiet mode NOT set\n" unless Rcs->quiet;

    $obj->rcsclean;

=head1 AUTHOR

Craig Freter, E<lt>F<craig@freter.com>E<gt>

=head1 COPYRIGHT

Copyright (C) 1997, Craig Freter.  All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
