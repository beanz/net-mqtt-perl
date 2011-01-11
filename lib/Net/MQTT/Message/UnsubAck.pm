use strict;
use warnings;
package Net::MQTT::Message::UnsubAck;

# ABSTRACT: Perl module to represent an MQTT UnsubAck message

=head1 SYNOPSIS

  # instantiated by Net::MQTT::Message

=head1 DESCRIPTION

This module encapsulates a single MQTT Unsubscribe Acknowledgement
message.  It is a specific subclass used by L<Net::MQTT::Message>
and should not need to be instantiated directly.

=cut

use base 'Net::MQTT::Message::JustMessageId';
use Net::MQTT::Constants qw/:all/;

sub message_type {
  11
}

=method C<message_id()>

Returns the message id field of the MQTT Unsubscribe Acknowledgement
message.

=cut

1;
