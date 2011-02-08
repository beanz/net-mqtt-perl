use strict;
use warnings;
package Net::MQTT::Message::Publish;

# ABSTRACT: Perl module to represent an MQTT Publish message

=head1 SYNOPSIS

  # instantiated by Net::MQTT::Message

=head1 DESCRIPTION

This module encapsulates a single MQTT Publish message.  It
is a specific subclass used by L<Net::MQTT::Message> and should
not need to be instantiated directly.

=cut

use base 'Net::MQTT::Message';
use Net::MQTT::Constants qw/:all/;

sub message_type {
  3
}

=method C<topic()>

Returns the topic field of the MQTT Publish message.

=cut

sub topic { shift->{topic} }

=method C<message_id()>

Returns the message id field of the MQTT Publish message.

=cut

sub message_id { shift->{message_id} }

=method C<message()>

Returns the message field of the MQTT Publish message.

=cut

sub message { shift->{message} }

sub _message_string { shift->{message} }

sub _remaining_string {
  my $self = shift;
  $self->topic.
    ($self->qos ? '/'.$self->message_id : '').
      ' '.dump_string($self->_message_string)
}

sub _parse_remaining {
  my $self = shift;
  my $offset = 0;
  $self->{topic} = decode_string($self->{remaining}, \$offset);
  $self->{message_id} = decode_short($self->{remaining}, \$offset)
    if ($self->qos);
  $self->{message} = substr $self->{remaining}, $offset;
  $self->{remaining} = '';
}

sub _remaining_bytes {
  my $self = shift;
  my $o = encode_string($self->topic);
  if ($self->qos) {
    $o .= encode_short($self->message_id);
  }
  $o .= $self->message;
  $o;
}

1;
