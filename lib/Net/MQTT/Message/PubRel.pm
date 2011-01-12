use strict;
use warnings;
package Net::MQTT::Message::PubRel;

# ABSTRACT: Perl module to represent an MQTT PubRel message

=head1 SYNOPSIS

  # instantiated by Net::MQTT::Message

=head1 DESCRIPTION

This module encapsulates a single MQTT Publish Release message.  It is
a specific subclass used by L<Net::MQTT::Message> and should not
need to be instantiated directly.

=cut

use base 'Net::MQTT::Message::JustMessageId';
use Net::MQTT::Constants qw/:all/;

sub message_type {
  6
}

sub _default_qos {
  MQTT_QOS_AT_LEAST_ONCE
}

=method C<message_id()>

Returns the message id field of the MQTT Publish Release message.

=cut

1;
