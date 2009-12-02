package Business::PayPal::API::VoidRequest;

use 5.008001;
use strict;
use warnings;

use SOAP::Lite 0.67;
use Business::PayPal::API ();

our @ISA = qw(Business::PayPal::API);
our $VERSION = '0.12';
our $CVS_VERSION = '$Id: VoidRequest.pm,v 1.2 2007/09/27 20:32:32 scott Exp $';
our @EXPORT_OK = qw(DoVoidRequest);

sub DoVoidRequest {
    my $self = shift;
    my %args = @_;

    my %types = ( AuthorizationID => 'xs:string',
                  Note            => 'xs:string', );


    my @ref_trans = 
      (
       $self->version_req,
       SOAP::Data->name( AuthorizationID => $args{AuthorizationID} )->type($types{AuthorizationID}),
      );

    if ($args{Note}) {
    push @ref_trans,
      SOAP::Data->name( Note => $args{Note} )->type( $types{Note} )
      if $args{Note};
    }
    my $request = SOAP::Data->name
      ( DoVoidRequest => \SOAP::Data->value( @ref_trans ) )
        ->type("ns:VoidRequestType");

    my $som = $self->doCall( DoVoidReq => $request )
      or return;

    my $path = '/Envelope/Body/DoVoidResponse';

    my %response = ();
    unless( $self->getBasic($som, $path, \%response) ) {
        $self->getErrors($som, $path, \%response);
        return %response;
    }

    $self->getFields($som, $path, \%response,
                     { AuthorizationID => 'AuthorizationID' }
                    );

    return %response;
}

1;
__END__

=head1 NAME

Business::PayPal::API::VoidRequest - PayPal VoidRequest API

=head1 SYNOPSIS

  use Business::PayPal::API::VoidRequest;

  ## see Business::PayPal::API documentation for parameters
  my $pp = new Business::PayPal::API::VoidRequest ( ... );

  my %response = $pp->DoVoidRequest( AuthorizationID => $transid
                                     Note            => "Please come again!" );

=head1 DESCRIPTION

B<Business::PayPal::API::VoidRequest> implements PayPal's
B<VoidRequest> API using SOAP::Lite to make direct API calls to
PayPal's SOAP API server. It also implements support for testing via
PayPal's I<sandbox>. Please see L<Business::PayPal::API> for details
on using the PayPal sandbox.

=head2 DoVoidRequest

Implements PayPal's B<DoVoidRequest> API call. Supported
parameters include:

  AuthorizationID
  Note

The B<AuthorizationID> is the original ID. Not a subsequent ID from a
B<ReAuthorizationRequest>. The note is a 255 character message for
whatever purpose you deem fit.

Returns a hash containing the results of the transaction. The B<Ack>
element is likely the only useful return value at the time of this
revision (the Nov. 2005 errata to the Web Services API indicates that
the documented fields 'AuthorizationID', 'GrossAmount', etc. are I<not>
returned with this API call).

Example:

  my %resp = $pp->DoVoidRequest( AuthorizationID => $trans_id,
                                 Note            => 'Sorry about that.' );

  unless( $resp{Ack} ne 'Success' ) {
      for my $error ( @{$response{Errors}} ) {
          warn "Error: " . $error->{LongMessage} . "\n";
      }
  }

=head2 ERROR HANDLING

See the B<ERROR HANDLING> section of B<Business::PayPal::API> for
information on handling errors.

=head2 EXPORT

None by default.

=head1 SEE ALSO

L<https://developer.paypal.com/en_US/pdf/PP_APIReference.pdf>

=head1 AUTHOR

Danny Hembree E<lt>danny@dynamical.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Danny Hembree

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.


=cut
