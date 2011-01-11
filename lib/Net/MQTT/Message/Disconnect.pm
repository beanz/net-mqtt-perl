use strict;
use warnings;
package Net::MQTT::Message::Disconnect;

# ABSTRACT: Perl module to represent an MQTT Disconnect message

=head1 SYNOPSIS

  # instantiated by Net::MQTT::Message

=head1 DESCRIPTION

This module encapsulates a single MQTT Disconnection Notification
message.  It is a specific subclass used by L<Net::MQTT::Message>
and should not need to be instantiated directly.

=cut

use base 'Net::MQTT::Message';

sub message_type {
  14
}

1;
