#!/usr/bin/perl
# Usage: "perl sound.pl | aplay -f dat"
use Data::Dumper;
use strict;
my $PI = 3.1415926;
my $A = 32000; # Max amplitude is 32768
my $sample_rate = 48000;
my $n_channels = 2; # 2=stereo
my $increment = $n_channels * (1/$sample_rate); # 2 * (1/48000) = 0.0000416666

sub beep {
my ($freq) = @_;
my $t = 0;
while (1) {
  $t += $increment; # Time in seconds
  my $signal_left = $A * sin($freq * 2 * $PI * $t) * $t;
  my $signal_right = $A * sin($freq * 2 * $PI * $t) * $t;
  # pack("v", ...) generates string in 16-bit little-endian format
  my $signal_left_pack = pack("v", $signal_left) . "\0\0";
  my $signal_right_pack = "\0\0" . pack("v", $signal_right);
  print $signal_left_pack;
  print $signal_right_pack;
  if ($t>1) {
    # Exit after 1 second
    return;
  }
}
}

my $a_freq = 440; # Frequency in Hertz (eg: 440 Hz is 'A' note)
my $b_freq = 523.25;
beep($a_freq);
beep($b_freq);
beep($a_freq);
beep($b_freq);
