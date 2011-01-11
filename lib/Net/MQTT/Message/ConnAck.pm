use strict;
use warnings;
package Net::MQTT::Message::ConnAck;

# ABSTRACT: Perl module to represent an MQTT ConnAck message

=head1 SYNOPSIS

  # instantiated by Net::MQTT::Message

=head1 DESCRIPTION

This module encapsulates a single MQTT Connection Acknowledgement
message.  It is a specific subclass used by L<Net::MQTT::Message>
and should not need to be instantiated directly.

=cut

use base 'Net::MQTT::Message';
use Net::MQTT::Constants qw/:all/;

sub message_type {
  2
}

=method C<connack_reserved()>

Returns the reserved field of the MQTT Connection Acknowledgement
message.

=cut

sub connack_reserved { shift->{connack_reserved} || 0 }

=method C<return_code()>

Returns the return code field of the MQTT Connection Acknowledgement
message.  The module L<Net::MQTT::Constants> provides a function,
C<connect_return_code_string>, that can be used to convert this value
to a human readable string.

=cut

sub return_code { shift->{return_code} || MQTT_CONNECT_ACCEPTED }

sub _remaining_string {
  my ($self, $prefix) = @_;
  connect_return_code_string($self->return_code).
    ' '.$self->SUPER::_remaining_string($prefix)
}

sub _parse_remaining {
  my $self = shift;
  $self->{connack_reserved} = decode_byte($self->{remaining});
  $self->{return_code} = decode_byte($self->{remaining});
}

sub _remaining_bytes {
  my $self = shift;
  my $o = encode_byte($self->connack_reserved);
  $o .= encode_byte($self->return_code);
}

1;
