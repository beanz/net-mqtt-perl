use strict;
use warnings;
package Net::MQTT::Message::Subscribe;

# ABSTRACT: Perl module to represent an MQTT Subscribe message

=head1 SYNOPSIS

  # instantiated by Net::MQTT::Message

=head1 DESCRIPTION

This module encapsulates a single MQTT Subscribe message.  It is a
specific subclass used by L<Net::MQTT::Message> and should not
need to be instantiated directly.

=cut

use base 'Net::MQTT::Message';
use Net::MQTT::Constants qw/:all/;

sub message_type {
  8
}

=method C<message_id()>

Returns the message id field of the MQTT Subscribe message.

=cut

sub message_id { shift->{message_id} }

=method C<topics()>

Returns the list of topics of the MQTT Subscribe message.  Each
element of the list is a 2-ple containing the topic and its associated
requested QoS level.

=cut

sub topics { shift->{topics} }

sub _topics_string {
  join  ',', map { $_->[0].'/'.qos_string($_->[1]) } @{shift->{topics}}
}

sub _remaining_string {
  my ($self, $prefix) = @_;
  $self->message_id.' '.$self->_topics_string.' '.
    $self->SUPER::_remaining_string($prefix)
}

sub _parse_remaining {
  my $self = shift;
  $self->{message_id} = decode_short($self->{remaining});
  while (length $self->{remaining}) {
    push @{$self->{topics}}, [ decode_string($self->{remaining}),
                               decode_byte($self->{remaining}) ];
  }
}

sub _remaining_bytes {
  my $self = shift;
  my $o = encode_short($self->message_id);
  foreach my $r (@{$self->topics}) {
    my ($name, $qos) = @$r;
    $o .= encode_string($name);
    $o .= encode_byte($qos);
  }
  $o
}

1;
