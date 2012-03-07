#!/usr/bin/env perl

use v5.14;
use Audio::NoiseGen ':all';

Audio::NoiseGen::init();

# play( gen =>
  # envelope(
    # attack => 0.1,
    # sustain => 20,
    # release => 0.1,
    # gen => combine( gens => [
      # segment( notes => 'A' ),
      # segment( notes => 'A B' ),
      # segment( notes => 'A B C' ),
      # segment( notes => 'A B C D' ),
      # # segment( notes => 'A B C D E' ),
      # # segment( notes => 'A B C D E F' ),
      # # segment( notes => 'A B C D E F G' ),
      # # segment( notes => 'A B C D E F G A5' ),
      # # segment( notes => 'A B C D E F G A5 B5' ),
      # # segment( notes => 'A B C D E F G A5 B5 C5' ),
  # ])));

my $n = segment( notes => 'A C R R' );

play( gen =>
  envelope( sustain => 10, gen =>
  sequence( gens => [
    lowpass( rc => 1, gen => $n),
    segment( notes => 'B R' ),
    lowpass( rc => 0.5, gen => $n),
    segment( notes => 'B R' ),
    lowpass( rc => 0.1, gen => $n),
    segment( notes => 'B R' ),
    lowpass( rc => 0.01, gen => $n),
    segment( notes => 'B R' ),
    lowpass( rc => 0.001, gen => $n),
    segment( notes => 'R R R R R' ),
  ])),
  filename => 'out.raw'
);

# play(
  # # lowpass_gen(

  # sequence_gen(
    # envelope_gen( attack => 0, sustain => 2, release => 0,
      # gen => highpass_gen( gen => white_noise_gen( freq => 440 ) ),
    # ),
  # )
# , 'out.raw');

# exit;

# my $lfo = sine_gen({ freq => 1 });
# my $wobble = sub { $lfo->() * 100 };
# my $wobble_a = envelope_gen(
  # { attack => 0.1, sustain => 0.3, decay => 0.3 },
  # sine_gen({
    # # freq => sub { $wobble->() }
    # freq => sub { $wobble->() + 220 }
    # # freq => 220
  # })
# );

# play(

  # amp_gen(
    # { amount => 0.5 },
    # sequence_gen(
      # $wobble_a,
      # $wobble_a,
      # $wobble_a,
      # # sine_gen({ freq => 1 }),
    # )
  # ),



# , 'out.raw');

