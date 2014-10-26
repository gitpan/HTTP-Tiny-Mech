use 5.006;    # pragmas, our
use strict;
use warnings;

package HTTP::Tiny::Mech;
$HTTP::Tiny::Mech::VERSION = '1.000000';
# ABSTRACT: Wrap a WWW::Mechanize instance in an HTTP::Tiny compatible interface.

our $AUTHORITY = 'cpan:KENTNL'; # AUTHORITY

use Class::Tiny {
  mechua => sub {
    require WWW::Mechanize;
    return WWW::Mechanize->new();
  },
};

# This is intentionally after Class::Tiny
# so that inheritance is
#
# HTTP::Tiny::Mech -> [ Class::Tiny::Object , HTTP::Tiny ]
#
# So that mechua is parsed by Class::Tiny::Object
#
use parent 'HTTP::Tiny';













































sub _unwrap_response {
  my ( undef, $response ) = @_;
  return {
    status  => $response->code,
    reason  => $response->message,
    headers => $response->headers,
    success => $response->is_success,
    content => $response->content,
  };
}

sub _wrap_request {
  my ( undef, $method, $uri, $opts ) = @_;
  require HTTP::Request;
  my $req = HTTP::Request->new( $method, $uri );
  $req->headers( $opts->{headers} ) if $opts->{headers};
  $req->content( $opts->{content} ) if $opts->{content};
  return $req;
}









sub get {
  my ( $self, $uri, $opts ) = @_;
  return $self->_unwrap_response( $self->mechua->get( $uri, ( $opts ? %{$opts} : () ) ) );
}







sub request {
  my ( $self, @request ) = @_;
  my $req      = $self->_wrap_request(@request);
  my $response = $self->mechua->request($req);
  return $self->_unwrap_response($response);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

HTTP::Tiny::Mech - Wrap a WWW::Mechanize instance in an HTTP::Tiny compatible interface.

=head1 VERSION

version 1.000000

=head1 SYNOPSIS

  # Get something that expects an HTTP::Tiny instance
  # to work with HTTP::Mechanize under the hood.
  #
  my $thing => ThingThatExpectsHTTPTiny->new(
    ua => HTTP::Tiny::Mech->new()
  );

  # Get something that expects HTTP::Tiny
  # to work via WWW::Mechanize::Cached
  #
  my $thing => ThingThatExpectsHTTPTiny->new(
    ua => HTTP::Tiny::Mech->new(
      mechua => WWW::Mechanize::Cached->new( )
    );
  );

=head1 DESCRIPTION

This code is somewhat poorly documented, and highly experimental.

Its the result of a quick bit of hacking to get L<< C<MetaCPAN::API>|MetaCPAN::API >> working faster
via the L<< C<WWW::Mechanize::Cached>|WWW::Mechanize::Cached >> module ( and gaining cache persistence via
L<< C<CHI>|CHI >> )

It works so far for this purpose.

At present, only L</get> and L</request> are implemented, and all other calls
fall through to a native L<< C<HTTP::Tiny>|HTTP::Tiny >>.

=head1 ATTRIBUTES

=head2 C<mechua>

This class provides one non-standard parameter not in HTTP::Tiny, C<mechua>, which
is normally an autovivified C<WWW::Mechanize> instance.

You may override this parameter if you want to provide a custom instance of a C<WWW::Mechanize> class.

=head1 WRAPPED METHODS

=head2 get

Interface should be the same as it is with L<HTTP::Tiny/get>.

=head2 request

Interface should be the same as it is with L<HTTP::Tiny/request>

=head1 AUTHORS

=over 4

=item *

Kent Fredric <kentnl@cpan.org>

=item *

Pedro Melo <melo@simplicidade.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
