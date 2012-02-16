#!/usr/bin/env perl

use v5.14;
use Audio::NoiseGen ':all';

Audio::NoiseGen::init();

my $lfo = sine_gen({ freq => 10 });
my $wobble = sub { $lfo->() * 100 };
my $wobble_a = envelope_gen(
  { attack => 0.1, sustain => 0.1, decay => 0.1 },
  sine_gen({
    # freq => sub { $wobble->() }
    freq => sub { $wobble->() + 220 }
    # freq => 220
  })
);

play(

  amp_gen(
    { amount => 0.5 },
    combine_gen(
      $wobble_a,
      # sine_gen({ freq => 1 }),
    )
  ),



, 'out.raw');

