#!/usr/bin/env perl

# This fancy thing is a looper!
#
# Notes are entered using xmousepos. On my touchscreen this is easy.
#
# Loops are recorded/played by keypressess of letters

use strict;
use Audio::NoiseGen qw( :all );
use List::Util qw( sum );
use Term::ReadKey;

ReadMode 3;
END { ReadMode 0 }

use IO::Handle;
STDIN->autoflush(1);
STDOUT->autoflush(1);

sub looper {
  my %params = Audio::NoiseGen::generalize( @_ );
  my %play_loops = ();
  my %record_loops = ();

  my $c = 0;
  sub {
    my $sample = $params{gen}->();

    # Look for action
    my $key = ($c++ % 1000) || ReadKey(-1); # not too often
    if(defined $key && $key =~ /[a-z]/) {
      # Check to see if it is being recorded
      if(defined $record_loops{$key}) {
        print "Playing $key\n";
        $play_loops{$key} = $record_loops{$key};
        delete $record_loops{$key};
      } else {
        print "Recording $key\n";
        delete $play_loops{$key};
        $record_loops{$key} = [];
      }
    }

    # Record loops
    foreach my $loop (keys %record_loops) {
      push @{$record_loops{$loop}}, $sample;
    }

    # Output the current sample
    my @output_samples = ($sample);

    # Get samples from play loops
    foreach my $loop (keys %play_loops) {
      my $loop_sample = shift @{ $play_loops{$loop} };
      push @{ $play_loops{$loop} }, $loop_sample;
      push @output_samples, $loop_sample;
    }

    # Compbine and output!
    @output_samples = map { $_ || 0 } @output_samples;
    my $output_sample = sum @output_samples;
    return $output_sample * (1 / (scalar @output_samples));

  }
}

sub mousefreq {
  my $c = 0;
  my ($x, $y) = (0, 0);
  return sub {
    # Don't update too often
    unless($c++ % 1000) {
      my ($new_x, $new_y) = split(' ', `xmousepos`);
      # return $x if $x == $new_x;
      $x = $new_x;
      # print "pos: $x, $y\n";
      # Snap to a note!
      my @freqs = values %note_freq;
      @freqs = sort { abs($a - $x) <=> abs($b - $x) } @freqs;
      # print "Freqs: @freqs\n\n";
      $x = shift @freqs;
    }
    return $x;
  }
}

sub mousevol {
  my $max = shift;
  my $c = 0;
  my ($x, $y) = (0, 0);
  return sub {
    # Don't update too often
    unless($c++ % 1000) {
      ($x, $y) = split(' ', `xmousepos`);
      # print "mosevol: " . ($y * (1 / $max)) . "\n";
    }
    return $y * (1 / $max);
  }
}

init();

play( gen =>
  looper( gen =>
    amp(
      amount => mousevol(800),
      gen => square(
        freq => mousefreq()
      )
    )
));
