#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Image::Rsvg' ) || print "Bail out!\n";
}

diag( "Testing Image::Rsvg $Image::Rsvg::VERSION, Perl $], $^X" );
