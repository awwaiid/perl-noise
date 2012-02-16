package Audio::NoiseGen;

# ABSTRACT: Helps you generate (structured) noise

use v5.10;
use warnings;
use parent 'Exporter';
use Audio::PortAudio;
use List::Util qw( sum );
use List::MoreUtils qw( none );

our ($sample_rate, $time_step, $stream);
my $pi = 3.14159265358979323846;

# Note => Frequency (Hz)
our %note_freq = (
  'C0'  => 16.35,   'C#0' => 17.32,   'Db0' => 17.32,
  'D0'  => 18.35,   'D#0' => 19.45,   'Eb0' => 19.45,
  'E0'  => 20.60,   'F0'  => 21.83,   'F#0' => 23.12,
  'Gb0' => 23.12,   'G0'  => 24.50,   'G#0' => 25.96,
  'Ab0' => 25.96,   'A0'  => 27.50,   'A#0' => 29.14,
  'Bb0' => 29.14,   'B0'  => 30.87,   'C1'  => 32.70,
  'C#1' => 34.65,   'Db1' => 34.65,   'D1'  => 36.71,
  'D#1' => 38.89,   'Eb1' => 38.89,   'E1'  => 41.20,
  'F1'  => 43.65,   'F#1' => 46.25,   'Gb1' => 46.25,
  'G1'  => 49.00,   'G#1' => 51.91,   'Ab1' => 51.91,
  'A1'  => 55.00,   'A#1' => 58.27,   'Bb1' => 58.27,
  'B1'  => 61.74,   'C2'  => 65.41,   'C#2' => 69.30,
  'Db2' => 69.30,   'D2'  => 73.42,   'D#2' => 77.78,
  'Eb2' => 77.78,   'E2'  => 82.41,   'F2'  => 87.31,
  'F#2' => 92.50,   'Gb2' => 92.50,   'G2'  => 98.00,
  'G#2' => 103.83,  'Ab2' => 103.83,  'A2'  => 110.00,
  'A#2' => 116.54,  'Bb2' => 116.54,  'B2'  => 123.47,
  'C3'  => 130.81,  'C#3' => 138.59,  'Db3' => 138.59,
  'D3'  => 146.83,  'D#3' => 155.56,  'Eb3' => 155.56,
  'E3'  => 164.81,  'F3'  => 174.61,  'F#3' => 185.00,
  'Gb3' => 185.00,  'G3'  => 196.00,  'G#3' => 207.65,
  'Ab3' => 207.65,  'A3'  => 220.00,  'A#3' => 233.08,
  'Bb3' => 233.08,  'B3'  => 246.94,  'C4'  => 261.63,
  'C#4' => 277.18,  'Db4' => 277.18,  'D4'  => 293.66,
  'D#4' => 311.13,  'Eb4' => 311.13,  'E4'  => 329.63,
  'F4'  => 349.23,  'F#4' => 369.99,  'Gb4' => 369.99,
  'G4'  => 392.00,  'G#4' => 415.30,  'Ab4' => 415.30,
  'A4'  => 440.00,  'A#4' => 466.16,  'Bb4' => 466.16,
  'B4'  => 493.88,  'C5'  => 523.25,  'C#5' => 554.37,
  'Db5' => 554.37,  'D5'  => 587.33,  'D#5' => 622.25,
  'Eb5' => 622.25,  'E5'  => 659.26,  'F5'  => 698.46,
  'F#5' => 739.99,  'Gb5' => 739.99,  'G5'  => 783.99,
  'G#5' => 830.61,  'Ab5' => 830.61,  'A5'  => 880.00,
  'A#5' => 932.33,  'Bb5' => 932.33,  'B5'  => 987.77,
  'C6'  => 1046.50, 'C#6' => 1108.73, 'Db6' => 1108.73,
  'D6'  => 1174.66, 'D#6' => 1244.51, 'Eb6' => 1244.51,
  'E6'  => 1318.51, 'F6'  => 1396.91, 'F#6' => 1479.98,
  'Gb6' => 1479.98, 'G6'  => 1567.98, 'G#6' => 1661.22,
  'Ab6' => 1661.22, 'A6'  => 1760.00, 'A#6' => 1864.66,
  'Bb6' => 1864.66, 'B6'  => 1975.53, 'C7'  => 2093.00,
  'C#7' => 2217.46, 'Db7' => 2217.46, 'D7'  => 2349.32,
  'D#7' => 2489.02, 'Eb7' => 2489.02, 'E7'  => 2637.02,
  'F7'  => 2793.83, 'F#7' => 2959.96, 'Gb7' => 2959.96,
  'G7'  => 3135.96, 'G#7' => 3322.44, 'Ab7' => 3322.44,
  'A7'  => 3520.00, 'A#7' => 3729.31, 'Bb7' => 3729.31,
  'B7'  => 3951.07, 'C8'  => 4186.01, 'C#8' => 4434.92,
  'Db8' => 4434.92, 'D8'  => 4698.64, 'D#8' => 4978.03,
  'Eb8' => 4978.03,
);

our @EXPORT_OK = qw(
  $sample_rate
  $time_step
  $stream
  %note_freq
  init
  play
  G
  sine_gen
  silence_gen
  noise_gen
  white_noise_gen
  triangle_gen
  square_gen
  envelope_gen
  combine_gen
  split_gen
  sequence_gen
  note_gen
  rest_gen
  segment_gen
  formula_gen
  hardlimit_gen
  amp_gen
  oneshot_gen
);

our %EXPORT_TAGS = (
  all => [ @EXPORT_OK ]
);

sub init {
  my $api = shift || Audio::PortAudio::default_host_api();
  my $device = shift || $api->default_output_device;
  $sample_rate = shift || 48000;
  $time_step = (1/$sample_rate); # 2 * (1/48000) = 0.0000416666
  $stream = $device->open_write_stream(
    {
      channel_count => 1,
    },
    $sample_rate,
    1000, # some sort of buffer size?
    0
  );
}

sub log10 {
  my $n = shift;
  return log($n)/log(10);
}

sub db {
  my $sample = shift;
  return (20 * log10(abs($sample)+0.00000001));
}

# Play a sequence until we get an undef
$mon = 0;
sub play {
  my $gen = shift;
  my $filename = shift;
  # sox -r 48k -e floating-point -b 32 out.raw out.wav
  my $file;
  if($filename) {
    open $file, '>', $filename
      or die "Error opening $filename: $!";
  }
  while (1) {
    my $raw_sample = '';
    for(1..1000) {
    # while(1) {
      my $sample = $gen->();
      if(defined $sample && ($sample > 1 || $sample < -1)) {
        print "CLIP: $sample\n";
        $sample = $sample > 1 ? 1 : -1;
      }
      # print "Sample: $sample\n";
      if(!defined $sample) {
        $stream->write($raw_sample);
        print $file $raw_sample if $file;
        return;
      }

      # printf "dB: %0.05f\n", db($sample)
        # unless $mon++ % 100;
        
      $raw_sample .= pack "f*", $sample;
    }
    # print "Sending sample block...";
    $stream->write($raw_sample);
    print $file $raw_sample if $file;
    # print "sent.\n";
  }
}

sub generalize {
  my $defaults = shift;
  my $ops = shift;
  my $params = {
    %$defaults,
    (ref $ops->[0] eq 'HASH' ? %{ shift @$ops } : ())
  };
  foreach my $name (keys %$params) {
    unless(ref $params->{$name} eq 'CODE') {
      my $val = $params->{$name};
      $params->{$name} = sub { $val };
    }
  }
  return $params;
}

sub sine_gen {
  my $params = generalize({
    freq => 440
  }, \@_ );

  my $angle = 0;
  return sub {
    my $sample = sin($angle);
    $angle += 2 * $pi * $time_step * $params->{freq}->();
    return $sample;
  };
}

sub hardlimit_gen {
  my $params = generalize({
    level => 1,
  }, \@_ );
  my $gen = shift;
  return sub {
    my $sample = $gen->();
    my $level = $params->{level}->();
    if($sample > $level) {
      return $level;
    }
    if($sample < -1*$level) {
      return -1 * $level;
    }
    return $sample;
  }
}

sub amp_gen {
  my $params = generalize({
    amount => 1,
  }, \@_ );
  my $gen = shift;
  return sub {
    my $sample = $gen->();
    defined $sample
      ? $sample * $params->{amount}->()
      : undef;
  }
}

sub silence_gen {
  return sub {
    return 0;
  };
}

sub noise_gen {
  my $params = generalize({
    delta => 0.01,
  }, \@_ );
  my $sample = 0;
  return sub {
    my $change = int(rand(2)) > 1 ? 1 : -1;
    $sample += $change * $params->{delta}->();
    if($sample > 1) {
      $sample = 1;
    }
    if($sample < -1) {
      $sample = -1;
    }
    return $sample;
  };
}

sub white_noise_gen {
  return sub {
    return (rand(2) - 1);
  };
}

sub triangle_gen {
  my $params = generalize({
    freq => 440
  }, \@_ );
  my $current_sample = 0;
  my $current_freq = 0;
  my $direction = 1;
  return sub {
    my $sample_count = (1 / $params->{freq}->()) * $sample_rate;
    my $sample = $current_freq;
    $current_freq += $direction * (4 / $sample_count);
    if($current_freq >= 1) {
      $current_freq = 1;
      $direction = -1;
    }
    if($current_freq <= -1) {
      $current_freq = -1;
      $direction = 1;
    }
    return $current_freq;
  };
}

sub square_gen {
  my $params = generalize({
    freq => 440
  }, \@_ );
  my $current_sample = 0;
  my $current_freq = 0;
  return sub {
    my $sample_count = (1 / $params->{freq}->()) * $sample_rate;
    $current_sample++;
    if($current_sample > $sample_count) {
      $current_sample = 1;
    }
    if($current_sample < $sample_count / 2) {
      return 1;
    }
    if($current_sample >= $sample_count / 2) {
      return -1;
    }
  };
}


sub envelope_gen {
  my $params = generalize({
    attack => 0,
    sustain => 0,
    release => 0,
  }, \@_ );
  my $gen = shift;

  my $attack_sample_count  = $params->{attack}->()  * $sample_rate;
  my $sustain_sample_count = $params->{sustain}->() * $sample_rate;
  my $release_sample_count = $params->{release}->() * $sample_rate;

  my $mode = 'attack';
  my $current_sample = 0;
  return sub {
    $current_sample++;
    if($mode eq 'attack') {
      if($current_sample > $attack_sample_count) {
        $current_sample = 1;
        $mode = 'sustain';
      } else {
        my $scale = $current_sample / $attack_sample_count;
        return $gen->() * $scale;
      }
    }
    if($mode eq 'sustain') {
      if($current_sample > $sustain_sample_count) {
        $current_sample = 1;
        $mode = 'release';
      } else {
        return $gen->();
      }
    }
    if($mode eq 'release') {
      if($current_sample > $release_sample_count) {
        $current_sample = 1;
        $mode = 'attack';
        return undef;
      } else {
        my $scale = 1 - ($current_sample / $release_sample_count);
        return $gen->() * $scale;
      }
    }
  };
}

sub combine_gen {
  my $params = generalize({ }, \@_ );
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
      my $sample = sum @samples;
      return $sample * (1 / (scalar @gens));
    }
  };
}

sub split_gen {
  my $params = generalize({
    count => 2,
  }, \@_ );
  my ($gen) = @_;
  return sub {
    my $sample = $gen->();
    return ($sample) x $params->{count}->();
  }
}

sub sequence_gen {
  my $params = generalize({ }, \@_ );
  my (@gens) = @_;
  my @g;
  return sub {
    (@g) = @gens unless @g;
    while(@g) {
      my $sample = $g[0]->();
      if(defined $sample) {
        return $sample;
      } else {
        shift @g;
      }
    }
    (@g) = @gens;
    return undef;
  };
}

sub oneshot_gen {
  my $gen = shift;
  sub {
    my $sample = $gen->();
    if(!defined $sample) {
      $gen = silence_gen();
      $sample = $gen->();
    }
    return $sample;
  }
}

# Plays a note through an envelope
sub note_gen {
  my $params = generalize({
    note    => 'A4',
    gen     => \&triangle_gen,
    sustain => 0.1,
  }, \@_ );

  my ($c, $e);
  return sub {
    $c ||= $params->{gen}->({
      freq => $note_freq{$params->{note}->()}
    });
    $e ||= envelope_gen( $params, $c );
    my $sample = $e->();
    if(! defined $sample) {
      undef $c;
      undef $e;
    }
    return $sample;
  }
}

sub rest_gen {
  my ($length) = @_;
  my $silence = silence_gen();
  return envelope_gen( { sustain => $length }, $silence );
}

sub segment_gen {
  my $notes = shift;
  $notes =~ s/^\s+//;
  $notes =~ s/\s+$//;
  my @notes = split /\s+/, $notes;
  my @gens = ();
  my $base = 0.5;
  foreach my $note (@notes) { 
    my ($n, $f) = split '/', $note;
    $f ||= 1;
    my $l = $base / $f;
    unless( $n =~ /\d$/ ) {
      $n .= '4';
    }
    if($n =~ /^R/) {
      push @gens, rest_gen($l);
    } else {
      push @gens, note_gen({
        note    => $n,
        attack  => 0.01,
        sustain => $l,
        release => 0.01
      });
    }
  }
  sequence_gen(@gens);
}

sub formula_gen {
  my $params = generalize({
    bits        => 8,
    sample_rate => 8000,
  }, \@_ );
  my $formula = shift;
  my $formula_increment = $params->{sample_rate}->() / $sample_rate;
  my $max = 2 ** $params->{bits}->();
  my $t = 0;
  return sub {
    $t += $formula_increment;
    local $_ = int $t;
    return (((
      $formula->(int $t)
    ) % $max - ($max/2))/($max/2))
  }
}

######################################
# Now let's pretend to be an object

use overload
  '+' => \&m_seq,
  '*' => \&m_combine,
  '""' => sub { },
;

sub new {
  my $class = shift;
  my $gen = shift;
  if(!ref $gen) {
    print STDERR "segement '$gen'\n";
    $gen = segment_gen($gen);
  # } elsif(ref $gen eq 'CODE') {
    # $gen = formula_gen($gen);
  }
  my $self = {
    gen => $gen,
  };
  bless $self, $class;
  return $self;
}

sub m_seq {
  my ($self, $other, $swap) = @_;
  my $s = sequence_gen($self->{gen}, $other->{gen});
  return Audio::NoiseGen->new($s);
}

sub m_combine {
  my ($self, $other, $swap) = @_;
  print STDERR "combine!\n";
  my $s = combine_gen($self->{gen}, $other->{gen});
  return Audio::NoiseGen->new($s);
}

sub G {
  my $x = shift;
  return Audio::NoiseGen->new($x);
}

sub mplay {
  my $self = shift;
  play($self->{gen});
}

# (
  # ( G('C C C') + G('E E E') )
  # * ( G('D') * G('E') * G('G') ) # chord
# )->mplay;

1;

