#!/usr/bin/perl
#
# Copyright (C) 2011 by Mark Hindess

use warnings;
use strict;
$|=1;

use Test::More tests => 18;
BEGIN { use_ok('Net::MQTT::Constants'); }

my $topic;
my $re;
my $sep = '\\/';

$topic = 'finance/stock/ibm/closingprice';
is(topic_to_regexp($topic), undef, 'simple topic');

$topic = 'finance/stock/ibm/#';
$re = topic_to_regexp($topic);
is($re, qr!^finance${sep}stock${sep}ibm.*$!, 'multi-level wildcard '.$topic);

foreach my $topic_name (qw!finance/stock/ibm
                           finance/stock/ibm/closingprice
                           finance/stock/ibm/currentprice!) {
  ok($topic_name =~ $re, '... matches '.$topic_name);
}

$topic = 'finance/stock/+';
$re = topic_to_regexp($topic);
is($re, qr!^finance${sep}stock${sep}[^/]*$!, 'single-level wildcard '.$topic);

foreach my $topic_name (qw!finance/stock/ibm finance/stock/xyz!) {
  ok($topic_name =~ $re, '... matches '.$topic_name);
}
foreach my $topic_name (qw!finance/stock/ibm/closingprice!) {
  ok($topic_name !~ $re, '... doesn\'t match '.$topic_name);
}

$topic = '+/+';
$re = topic_to_regexp($topic);
is($re, qr!^[^/]*${sep}[^/]*$!, 'single-level wildcard '.$topic);
ok('/finance' =~ $re, '... matches /finance');

$topic = '/+';
$re = topic_to_regexp($topic);
is($re, qr!^${sep}[^/]*$!, 'single-level wildcard '.$topic);
ok('/finance' =~ $re, '... matches /finance');

$topic = '+';
$re = topic_to_regexp($topic);
is($re, qr!^[^/]*$!, 'single-level wildcard '.$topic);
ok('/finance' !~ $re, '... doesn\'t match /finance');

$topic = '$SYS/#';
$re = topic_to_regexp($topic);
is($re, qr!^\$SYS.*$!, 'single-level wildcard '.$topic);
ok('$SYS/test' =~ $re, '... matches $SYS/test');
