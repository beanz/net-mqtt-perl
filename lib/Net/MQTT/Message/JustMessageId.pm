use strict;
use warnings;
package Net::MQTT::Message::JustMessageId;

# ABSTRACT: Perl module for an MQTT message w/message id only payload

=head1 SYNOPSIS

  # abstract class not instantiated directly

=head1 DESCRIPTION

This module encapsulates a single MQTT message that has only a message id
in its payload.  This is an abstract class used to implement a number
of other MQTT messages such as PubAck, PubComp, etc.

=cut

use base 'Net::MQTT::Message';
use Net::MQTT::Constants qw/:all/;

=method C<message_id()>

Returns the message id field of the MQTT message.

=cut

sub message_id { shift->{message_id} }

sub _remaining_string {
  my ($self, $prefix) = @_;
  $self->message_id.' '.$self->SUPER::_remaining_string($prefix)
}

sub _parse_remaining {
  my $self = shift;
  my $offset = 0;
  $self->{message_id} = decode_short($self->{remaining}, \$offset);
  substr $self->{remaining}, 0, $offset, '';
}

sub _remaining_bytes {
  my $self = shift;
  encode_short($self->message_id)
}

1;
