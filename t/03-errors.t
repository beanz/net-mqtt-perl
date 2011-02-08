#!/usr/bin/perl
#
# Copyright (C) 2011 by Mark Hindess

use warnings;
use strict;
$|=1;

use Test::More tests => 7;
BEGIN { use_ok('Net::MQTT::Constants'); }
use_ok('Net::MQTT::Message');

my $offset = 0;
is(test_error(sub { decode_byte('', \$offset) }),
   'decode_byte: insufficient data', 'decode_byte error');
is(test_error(sub { decode_short('1', \$offset) }),
   'decode_short: insufficient data', 'decode_short error');
is(test_error(sub { decode_string((pack 'H*', '00'), \$offset) }),
   'decode_short: insufficient data',
   'decode_string error in short');
is(test_error(sub { decode_string((pack 'H*', '000201'), \$offset) }),
   'decode_string: insufficient data',
   'decode_string error in string');

is(Net::MQTT::Message->new_from_bytes(pack "H*", "C080"), undef,
   'just return undef if we are decoding remaining length');

sub test_error {
  my $sub = shift;
  eval { $sub->() };
  my $error = $@;
  if ($error) {
    $error =~ s/\s+at (\S+|\(eval \d+\)(\[[^]]+\])?) line \d+\.?\s*$//g;
    $error =~ s/\s+at (\S+|\(eval \d+\)(\[[^]]+\])?) line \d+\.?\s*$//g;
    $error =~ s/ \(\@INC contains:.*?\)$//;
  }
  return $error;
}

sub test_warn {
  my $sub = shift;
  my $warn;
  local $SIG{__WARN__} = sub { $warn .= $_[0]; };
  eval { $sub->(); };
  die $@ if ($@);
  if ($warn) {
    $warn =~ s/\s+at (\S+|\(eval \d+\)(\[[^]]+\])?) line \d+\.?\s*$//g;
    $warn =~ s/\s+at (\S+|\(eval \d+\)(\[[^]]+\])?) line \d+\.?\s*$//g;
    $warn =~ s/ \(\@INC contains:.*?\)$//;
  }
  return $warn;
}
