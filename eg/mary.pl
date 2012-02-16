#!/usr/bin/env perl

use strict;
use Audio::NoiseGen ':all';
Audio::NoiseGen::init();

play(
  envelope_gen(
    { attack => 0.2, sustain => 14.5, decay => 0.2 },
    combine_gen(
      segment_gen('
        E D C D
        E E E R
        D D D R
        E E E R
        E D C D
        E E E/2 E
        D D E D C
      '),
      segment_gen('A2 R R R'),
      segment_gen('C3/2 E3/4 E3/4 C3/2 F3 R'),
    ),
  )
);

