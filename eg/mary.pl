#!/usr/bin/env perl

use strict;
use Audio::NoiseGen ':all';
Audio::NoiseGen::init();

use List::Util qw( reduce );
use List::MoreUtils qw( none );

sub noisify {
  my $g = shift;
  my $width = shift || 0.001;
  return sub {
    my $sample = $g->();
    return undef if ! defined $sample;
    $sample += (rand $width) - ($width / 2);
  }
}

sub mult_gen {
  my (@gens) = @_;
  my @g;
  return sub {
    (@g) = @gens unless @g;
    my @samples = map { $_->() } @g;
    if(none { defined } @samples) {
      (@g) = @gens;
      return undef;
    } else {
      @samples = map { $_ || 0 } @samples;
      my $sample = reduce { $a * $b } @samples;
      return $sample;
    }
  };
}

play(
  envelope_gen(
    { sustain => 10 },
    combine_gen(
      segment_gen('E D C D E E E R D D D R E E E R E D C D E E E/2 E D D E D C'),
      segment_gen('A'),
      segment_gen('C3/2 E3/4 E3/4 C3/2 F3 R'),
      # formula_gen( sub {
        # $_ * (42 & $_ >> 10)
      # }),
      # formula_gen( sub {
        # ( $_ *( $_ >>8| $_ >>9)&46& $_ >>8)^( $_ & $_ >>13| $_ >>6)
      # }),
    ),
  )
);

# play(
  # env({ attack => 0, sustain => 10, release => 0 },
    # mult(
      # seg('A E F'),
      # lfo({ freq => 10 },
        # seg('C3/2 R')
      # ),
    # ),
  # ),
# );

