use strict;
use warnings;
package Net::MQTT::Message;

# ABSTRACT: Perl module to represent MQTT messages

=head1 SYNOPSIS

  use Net::MQTT::Constants;
  use Net::MQTT::Message;
  my $mqtt = Net::MQTT::Message->new(message_type => MQTT_CONNECT);
  print $socket $mqtt->bytes;

  my $mqtt = Net::MQTT::Message->new_from_bytes($tcp_payload);
  print 'Received: ', $mqtt->string, "\n";

=head1 DESCRIPTION

This module encapsulates a single MQTT message.  It uses subclasses to
represent specific message types.

=cut

use Net::MQTT::Constants qw/:all/;
use Module::Pluggable search_path => __PACKAGE__, require => 1;

our %types;
foreach (plugins()) {
  my $m = $_.'::message_type';
  next unless (defined &{$m}); # avoid super classes
  my $t = $_->message_type;
  if (exists $types{$t}) {
    die 'Duplicate message_type number ', $t, ":\n",
      '  ', $_, " and\n",
        '  ', $types{$t}, "\n";
  }
  $types{$t} = $_;
}

=method C<new( %parameters )>

Constructs an L<Net::MQTT::Message> object based on the given
parameters.  The common parameter keys are:

=over

=item C<message_type>

The message type field of the MQTT message.  This should be an integer
between 0 and 15 inclusive.  The module L<Net::MQTT::Constants>
provides constants that can be used for this value.  This parameter
is required.

=item C<dup>

The duplicate flag field of the MQTT message.  This should be either 1
or 0.  The default is 0.

=item C<qos>

The QoS field of the MQTT message.  This should be an integer between
0 and 3 inclusive.  The default is as specified in the spec or 0 ("at
most once") otherwise.  The module L<Net::MQTT::Constants> provides
constants that can be used for this value.

=item C<retain>

The retain flag field of the MQTT message.  This should be either 1
or 0.  The default is 0.

=back

The remaining keys are dependent on the specific message type.  The
documentation for the subclasses for each message type list methods
with the same name as the required keys.

=cut

sub new {
  my ($pkg, %p) = @_;
  my $type_pkg =
    exists $types{$p{message_type}} ? $types{$p{message_type}} : $pkg;
  bless { %p }, $type_pkg;
}

=method C<new_from_bytes( $packed_bytes, [ $splice ] )>

Attempts to constructs an L<Net::MQTT::Message> object based on
the given packed byte string.  If there are insufficient bytes, then
undef is returned.  If the splice parameter is provided and true, then
the processed bytes are removed from the scalar referenced by the
$packed_bytes parameter.

=cut

sub new_from_bytes {
  my ($pkg, $bytes, $splice) = @_;
  my %p;
  return if (length $bytes < 2);
  my $b = decode_byte($bytes);
  $p{message_type} = ($b&0xf0) >> 4;
  $p{dup} = ($b&0x8)>>3;
  $p{qos} = ($b&0x6)>>1;
  $p{retain} = ($b&0x1);
  my ($length, $remaining_length_length);
  eval {
    ($length, $remaining_length_length) = decode_remaining_length($bytes);
  };
  return if ($@);
  if (length $bytes < $length) {
    return
  }
  substr $_[1], 0, 1+$remaining_length_length+$length, '' if ($splice);
  $p{remaining} = substr $bytes, 0, $length;
  my $self = $pkg->new(%p);
  $self->_parse_remaining();
  $self;
}

sub _parse_remaining {
}

=method C<message_type()>

Returns the message type field of the MQTT message.  The module
L<Net::MQTT::Constants> provides a function, C<message_type_string>,
that can be used to convert this value to a human readable string.

=cut

sub message_type { shift->{message_type} }

=method C<dup()>

The duplicate flag field of the MQTT message.

=cut

sub dup { shift->{dup} || 0 }

=method C<qos()>

The QoS field of the MQTT message.  The module
L<Net::MQTT::Constants> provides a function, C<qos_string>, that
can be used to convert this value to a human readable string.

=cut

sub qos {
  my $self = shift;
  defined $self->{qos} ? $self->{qos} : $self->_default_qos
}

sub _default_qos {
  MQTT_QOS_AT_MOST_ONCE
}

=method C<retain()>

The retain field of the MQTT message.

=cut

sub retain { shift->{retain} || 0 }

=method C<remaining()>

This contains a packed string of bytes with any of the payload of the
MQTT message that was not parsed by these modules.  This should not
be required for packets that strictly follow the standard.

=cut

sub remaining { shift->{remaining} || '' }

sub _remaining_string {
  my ($self, $prefix) = @_;
  dump_string($self->remaining, $prefix);
}

sub _remaining_bytes { shift->remaining }

=method C<string([ $prefix ])>

Returns a summary of the message as a string suitable for logging.
If provided, each line will be prefixed by the optional prefix.

=cut

sub string {
  my ($self, $prefix) = @_;
  $prefix = '' unless (defined $prefix);
  my @attr;
  push @attr, qos_string($self->qos);
  foreach (qw/dup retain/) {
    my $bool = $self->$_;
    push @attr, $_ if ($bool);
  }
  my $r = $self->_remaining_string($prefix);
  $prefix.message_type_string($self->message_type).
    '/'.(join ',', @attr).($r ? ' '.$r : '')
}

=method C<bytes()>

Returns the bytes of the message suitable for writing to a socket.

=cut

sub bytes {
  my ($self) = shift;
  my $o = '';
  my $b =
    ($self->message_type << 4) | ($self->dup << 3) |
      ($self->qos << 1) | $self->retain;
  $o .= encode_byte($b);
  my $remaining = $self->_remaining_bytes;
  $o .= encode_remaining_length(length $remaining);
  $o .= $remaining;
  $o;
}

1;
