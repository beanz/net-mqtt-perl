use strict;
use warnings;
package Net::MQTT::TopicStore;

# ABSTRACT: Perl module to represent MQTT topic store

=head1 SYNOPSIS

  use Net::MQTT::TopicStore;
  my $topic_store = Net::MQTT::TopicStore->new();
  $topic_store->add($topic_pattern1);
  $topic_store->add($topic_pattern2);
  my @topics = @{ $topic->get($topic) };
  $topic_store->remove($topic_pattern2);

=head1 DESCRIPTION

This module encapsulates a single MQTT topic store.

=method C<new( )>

Constructs a L<Net::MQTT::TopicStore> object.

=cut

sub new {
  my $pkg = shift;
  my $self = bless { topics => { } }, $pkg;
  $self->add($_) foreach (@_);
  $self
}

=method C<add( $topic_pattern )>

Adds the topic pattern to the store.

=cut

sub add {
  my ($self, $topic, $value) = @_;
  unless (exists $self->{topics}->{$topic}) {
    $self->{topics}->{$topic} = _topic_to_regexp($topic);
  }
  $topic
}

=method C<delete( $topic_pattern )>

Remove the topic pattern from the store.

=cut

sub delete {
  my ($self, $topic) = @_;
  delete $self->{topics}->{$topic};
}

=method C<values( $topic )>

Returns all the topic patterns in the store that apply to the given topic.

=cut

sub values {
  my ($self, $topic) = @_;
  my @res = ();
  foreach my $t (keys %{$self->{topics}}) {
    my $re = $self->{topics}->{$t};
    next unless (defined $re ? $topic =~ $re : $topic eq $t);
    push @res, $t;
  }
  return \@res;
}

sub _topic_to_regexp {
  my $topic = shift;
  my $c;
  $topic = quotemeta $topic;
  $c += ($topic =~ s!\\/\\\+!\\/[^/]*!g);
  $c += ($topic =~ s!\\/\\#$!(?:\$|/.*)!);
  $c += ($topic =~ s!^\\\+\\/![^/]*\\/!g);
  $c += ($topic =~ s!^\\\+$![^/]*!g);
  $c += ($topic =~ s!^\\#$!.*!);
  $topic .= '$' unless ($topic =~ m!\$$!);
  unless ($c) {
    return;
  }
  qr/^$topic/
}

1;

