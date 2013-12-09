
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Perl module to represent MQTT messages",
  "AUTHOR" => "Mark Hindess <soft-cpan\@temporalanomaly.com>",
  "BUILD_REQUIRES" => {
    "Test::More" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Net-MQTT",
  "EXE_FILES" => [
    "bin/net-mqtt-pub",
    "bin/net-mqtt-trace",
    "bin/net-mqtt-sub"
  ],
  "LICENSE" => "perl",
  "NAME" => "Net::MQTT",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Getopt::Long" => 0,
    "IO::Select" => 0,
    "IO::Socket::INET" => 0,
    "Module::Pluggable" => 0,
    "Pod::Usage" => 0,
    "Time::HiRes" => 0,
    "base" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "1.133430",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



