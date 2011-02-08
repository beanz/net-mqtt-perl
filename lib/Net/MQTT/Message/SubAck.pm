use strict;
use warnings;
package Net::MQTT::Message::SubAck;

# ABSTRACT: Perl module to represent an MQTT SubAck message

=head1 SYNOPSIS

  # instantiated by Net::MQTT::Message

=head1 DESCRIPTION

This module encapsulates a single MQTT Subscription Acknowledgement
message.  It is a specific subclass used by L<Net::MQTT::Message>
and should not need to be instantiated directly.

=cut

use base 'Net::MQTT::Message';
use Net::MQTT::Constants qw/:all/;

sub message_type {
  9
}

=method C<message_id()>

Returns the message id field of the MQTT Subscription Acknowledgement
message.

=cut

sub message_id { shift->{message_id} }

=method C<qos_levels()>

Returns the list of granted QoS fields of the MQTT Subscription
Acknowledgement message.

=cut

sub qos_levels { shift->{qos_levels} }

sub _remaining_string {
  my ($self, $prefix) = @_;
  $self->message_id.'/'.
    (join ',', map { qos_string($_) } @{$self->qos_levels}).
    ' '.$self->SUPER::_remaining_string($prefix)
}

sub _parse_remaining {
  my $self = shift;
  my $offset = 0;
  $self->{message_id} = decode_short($self->{remaining}, \$offset);
  while ($offset < length $self->{remaining}) {
    push @{$self->{qos_levels}}, decode_byte($self->{remaining}, \$offset)&0x3;
  }
  substr $self->{remaining}, 0, $offset, '';
}

sub _remaining_bytes {
  my $self = shift;
  my $o = encode_short($self->message_id);
  foreach my $qos (@{$self->qos_levels}) {
    $o .= encode_byte($qos);
  }
  $o
}


1;
