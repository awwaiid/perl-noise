#!/usr/bin/perl

use strict;
use Audio::PortAudio;

my $sample_rate = 48000;
my $increment = (1/$sample_rate); # 2 * (1/48000) = 0.0000416666
my $pi = 3.14159265358979323846;

my $api = Audio::PortAudio::default_host_api();
my $device  = $api->default_output_device;

my $stream = $device->open_write_stream( {
    channel_count => 1,
  },
  $sample_rate,
  10, # some sort of buffer size?
  0
);

sub beep {
  my ($freq, $length) = @_;
  my $sample_count = $length * $sample_rate;
  my $sine = pack "f*", map {
    sin( $increment * $pi * $_ * 2 * $freq ) * (1 - ($_ / $sample_count))
  } 0 .. $sample_count;
  $stream->write($sine);
}

my $a3 = 220; # Frequency in Hertz (eg: 440 Hz is 'A' note)
my $b3 = 246.94;
my $a4 = 440; # Frequency in Hertz (eg: 440 Hz is 'A' note)
my $b4 = 523.25;

while(1) {
  map { beep($_, 0.1) }
    $a4,
    $b4,
    $a4,
    $b4,
    $a3,
    $b3,
    $a3,
    $b3;
  
  # beep($a3,0.1);
  # beep($b3,0.1);
  # beep($a3,0.1);
  # beep($b3,0.1);
  # beep($a3,0.1);
  # beep($b3,0.1);
}

