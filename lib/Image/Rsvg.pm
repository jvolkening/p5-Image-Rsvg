package Image::Rsvg 0.001;

use 5.012;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Image::Rsvg - Bindings to the librsvg 2.0 SVG rendering library

=head1 SYNOPSIS

  use Image::Rsvg;

  # initialize using filename 
  my $svg = Image::Rsvg::Handle->new_from_file( 'file.svg' );

  # or, initialize using scalar data
  open my $fh, '<:raw', 'file.pdf';
  read ($fh, my $data, -s 'file.pdf')
  close $fh;
  my $svg = Image::Rsvg::Handle->new_from_data( $data );

  # get some general info
  my $dims = $svg->get_dimensions;
  my $w = $dims->{width};
  my $h = $dims->{height};
  # etc ...

  # render to a Cairo surface
  use Cairo;
  use Cairo::GObject;
  my $surface = Cairo::ImageSurface->create( 'argb32', $w, $h );
  my $cr = Cairo::Context->create( $surface );
  $page->render_cairo( $cr );
  $cr->show_page;

=head1 ABSTRACT

Bindings to the librsvg SVG library using gobject introspection. Allows
rendering of SVG images to Cairo contexts and GDK pixbufs.

=head1 DESCRIPTION

The C<Image::Rsvg> module provides complete bindings to the librsvg SVG
rendering library via gobject introspection. Find out more about librsvg at
L<https://developer.gnome.org/rsvg/>.

No XS is used directly but bindings are provided using GObject introspection
and the L<Glib::Object::Introspection> module. See the L<Image::Rsvg/SYNOPSIS>
for a brief example of how the module can be used. For detailed documentation
on the available classes and methods, see the librsvg documentation for
the C libraries and the L<Glib::Object::Introspection> documentation for a
description of how methods are mapped between the C libraries and the Perl
namespace.

=head1 CONSTRUCTORS

=over

=item new_from_file ($filename)

Takes a path to an SVG file as an argument and returns an Image::Rsvg::Handle
object. 

=item new_from_data ($data)

Takes an SVG data chunk as an argument and returns an Image::Rsvg::Handle object.

=back

=head1 METHODS

For details on the classes and methods available beyond the constructors
listed above, please refer to the canonical documentation for the C library
listed under L<Image::Rsvg::Handle/SEE ALSO>. A general discussion of how
these classes and methods map to the Perl equivalents can be found in the
L<Glib::Object::Introspection> documentation. Generally speaking, a C function
such as 'rsvg_handle_get_dimensions' would map to
'Image::Rsvg::Handle->get_dimensions'.

=cut

use strict;
use warnings;
use Carp qw/croak/;
use Cwd qw/abs_path/;
use Exporter;
use File::ShareDir;
use Glib::Object::Introspection;

our @ISA = qw(Exporter);

my $_RSVG_BASENAME = 'Rsvg';
my $_RSVG_VERSION  = '2.0';
my $_RSVG_PACKAGE  = 'Image::Rsvg';

=head2 Customizations and overrides

In order to make things more Perlish, C<Image::Rsvg> customizes the API generated
by L<Glib::Object::Introspection> in a few spots:

=over

=item * The following functions normally return a boolean and additional out
arguments, where the boolean indicates whether the out arguments are valid.
They are altered such that when the boolean is true, only the additional out
arguments are returned, and when the boolean is false, an empty list is
returned.

=over

=item Image::Rsvg::Handle::get_dimensions_sub

=item Image::Rsvg::Handle::get_position_sub

=back

=cut

my @_RSVG_HANDLE_SENTINEL_BOOLEAN_FOR = qw/
  Image::Rsvg::Handle::get_dimensions_sub
  Image::Rsvg::Handle::get_position_sub
/;


# - Wiring ------------------------------------------------------------------ #

sub import {

  Glib::Object::Introspection->setup (
    search_path => File::ShareDir::dist_dir('Image-Rsvg'),
    basename    => $_RSVG_BASENAME,
    version     => $_RSVG_VERSION,
    package     => $_RSVG_PACKAGE,
    handle_sentinel_boolean_for  => \@_RSVG_HANDLE_SENTINEL_BOOLEAN_FOR,
  );

  # call into Exporter for the unrecognized arguments; handles exporting and
  # version checking
  Image::Rsvg->export_to_level (1, @_);

}

# - Overrides --------------------------------------------------------------- #

=item * Perl reimplementations of C<Image::Rsvg::Handler::new_from_data>
and C<Image::Rsvg::Handler::write> are provided which remove the need to
provide the data length as a second argument (as well as handling internal
data conversion). It should be provided a single argument, a scalar containing
the SVG data:

    $h = Image::Rsvg::Handle->new_from_data( $svg );

    #or

    $h = Image::Rsvg::Handle->new();
    while (<$svg>) {
        $h->write($_);
    }
    $h->close;

=back

=cut

# These were worked out based on the Gtk3 module

sub Image::Rsvg::Handle::new_from_data {

    my ($self, $data) = @_;

    return Glib::Object::Introspection->invoke (
        $_RSVG_BASENAME, 'Handle', 'new_from_data',
        $self, _unpack_unless_array_ref ($data)
    );
}

sub Image::Rsvg::Handle::write {

    my ($self, $data) = @_;

    return Glib::Object::Introspection->invoke (
        $_RSVG_BASENAME, 'Handle', 'write',
        $self, _unpack_unless_array_ref ($data)
    );
}

# Taken directly from Gtk3 module

sub _unpack_unless_array_ref {
  my ($data) = @_;
  local $@;
  return eval { @{$data} }
    ? $data
    : [unpack 'C*', $data];
}

1;

__END__


=head1 SEE ALSO

=over

=item * C library documentation for librsvg at
L<https://developer.gnome.org/rsvg/>.

=item * L<Glib>

=item * L<Glib::Object::Introspection>

=item * L<Image::LibRSVG>

=item * L<Gnome2::Rsvg>

=item * L<XML::LibRSVG>

=item * L<SVG::Rasterize>

=back

=head1 AUTHORS

=over

=item 2016 Jeremy Volkening <jdv@base2bio.com>

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 by Jeremy Volkening

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
