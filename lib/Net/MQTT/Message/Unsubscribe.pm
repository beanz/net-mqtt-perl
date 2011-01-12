use strict;
use warnings;
package Net::MQTT::Message::Unsubscribe;

# ABSTRACT: Perl module to represent an MQTT Unsubscribe message

=head1 SYNOPSIS

  # instantiated by Net::MQTT::Message

=head1 DESCRIPTION

This module encapsulates a single MQTT Unsubscribe message.  It is a
specific subclass used by L<Net::MQTT::Message> and should not
need to be instantiated directly.

=cut

use base 'Net::MQTT::Message';
use Net::MQTT::Constants qw/:all/;

sub message_type {
  10
}

sub _default_qos {
  MQTT_QOS_AT_LEAST_ONCE
}

=method C<message_id()>

Returns the message id field of the MQTT Unsubscribe message.

=cut

sub message_id { shift->{message_id} }

=method C<topics()>

Returns the list of topics of the MQTT Subscribe message.

=cut

sub topics { shift->{topics} }

sub _topics_string { join  ',', @{shift->{topics}} }

sub _remaining_string {
  my ($self, $prefix) = @_;
  $self->message_id.' '.$self->_topics_string.' '.
    $self->SUPER::_remaining_string($prefix)
}

sub _parse_remaining {
  my $self = shift;
  $self->{message_id} = decode_short($self->{remaining});
  while (length $self->{remaining}) {
    push @{$self->{topics}}, decode_string($self->{remaining});
  }
}

sub _remaining_bytes {
  my $self = shift;
  my $o = encode_short($self->message_id);
  foreach my $name (@{$self->topics}) {
    $o .= encode_string($name);
  }
  $o
}

1;
