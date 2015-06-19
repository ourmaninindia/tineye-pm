#!/usr/bin/env perl

use strict;
use warnings;

use lib qw{.};
use TinyEyeSearch;
use Data::Dumper;

use Getopt::Long;

my $test = 0;
my $limit = 100;

GetOptions(
    test => \$test,
    'limit=i' => \$limit,
) or die "Invalid Options";


print "Running with test = $test and limit = $limit\n";
print Dumper TinyEyeSearch::search('http://tineye.com/images/tineye_logo_big.png', $test, 0, $limit);

exit;
