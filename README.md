Image::Rsvg
============

Image::Rsvg provides bindings to the librsvg 2.0 rendering library using gobject
introspection. It can be used in combination with Cairo to render SVG images
to various output file formats or to GDK pixbufs.

INSTALLATION
------------

To install this module type the following:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install


DEPENDENCIES
------------

This module requires/recommends these C libraries:

  * rsvg-2.0

  * glib

  * cairo (recommended)

and these Perl modules:

  * Glib::Object::Introspection

  * Cairo (recommended - for rendering to cairo context)

COPYRIGHT AND LICENCE
---------------------

Copyright (C) 2016 by Jeremy Volkening (jdv@base2bio.com)

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.
