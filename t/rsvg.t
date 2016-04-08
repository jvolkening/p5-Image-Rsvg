#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use FindBin;
use Image::Rsvg;

chdir $FindBin::Bin;

require_ok ("Image::Rsvg");

my $fn1 = 'Perl_Onion.svg';

# input from filename

ok (my $svg = Image::Rsvg::Handle->new_from_file($fn1), "loaded from filename");
ok (my $dims = $svg->get_dimensions, "Queried dimensions");
ok ($dims->{width} == 283, "Matched width");
ok ($svg->has_sub("#path2995"), "Found existing element");
ok (! $svg->has_sub("#path2996"), "Did not find nonexistent element");

# input from data blob

open my $in, '<:raw', $fn1 or die "Failed file open";
my $want = -s $fn1;
my $r = read( $in, my $data, $want);
die "File read byte mismatch" if ($r != $want);
close $in;

ok ($svg = Image::Rsvg::Handle->new_from_data($data), "loaded from scalar");
ok ($dims = $svg->get_dimensions, "Queried dimensions");
ok ($dims->{width} == 283, "Matched width");
ok ($svg->has_sub("#path2995"), "Found existing element");
ok (! $svg->has_sub("#path2996"), "Did not find nonexistent element");

# input piecemeal

ok ($svg = Image::Rsvg::Handle->new(), "Loaded empty object");
open $in, '<', $fn1 or die "Failed file open";
while (<$in>) {
    $svg->write($_);
}
close $in;
ok ($svg->close, "Closed after read");

ok ($dims = $svg->get_dimensions, "Queried dimensions");
ok ($dims->{width} == 283, "Matched width");
ok ($svg->has_sub("#path2995"), "Found existing element");
ok (! $svg->has_sub("#path2996"), "Did not find nonexistent element");

done_testing();
exit;
