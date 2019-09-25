package Util::Importer {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules 
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;

  use lib 'lib/';

  ##############################################################################
  # Import subroutine
  ##############################################################################
  sub Import {
  
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get data passed to function 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $state = shift;
   
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my @seed = split //, $state->{seed};
    my %seed_data;
    my $key_counter = -1;
    my $value = '';
    my $counter = 0;

    # check seed start
    if ($seed[0] =~ m/[0-9]/) {
      die "Invalid seed.";
    }
    
    # print debug message
    $debugger->write("[IMPRT]: Using seed: $state->{seed}");

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # decompose the seed
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    foreach my $current_char (@seed) {
      if ($current_char !~ m/[0-9]/) {
        $key_counter++;
        $seed_data{$key_counter} = 'NULL';
        $value = '';
        next;
      }
      if ($current_char =~ m/[0-9]/) {
        $value = $value . $current_char;
        $seed_data{$key_counter} = $value;
      }
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # check difficulty and set seed data 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    foreach(keys %seed_data) {
      if ($seed_data{$_} eq 'NULL') {
        $seed_data{$_} = 0;
      }
      $counter++;
    }
    
    # check if there even is data in the seed_data
    $debugger->write("[IMPRT]: Total seed lenght: $counter");
    if ($counter == 0) {
      die "Seed import failed. Invalid seed";
    }

    # save difficulty
    $debugger->write("[IMPRT]: overriding difficulty to $seed_data{0}");
    $state->{difficulty} = $seed_data{0};

    # check if the number of keys matches the difficulty

    # difficulty 0, difficulty, pistol, weapon
    if ($state->{difficulty} >= 0) {
      die "Seed import failed. Invalid seed" unless $counter >= 3;
    }

    # difficulty 1, difficulty, pistol, weapon, grenade1, grenade2
    if ($state->{difficulty} >= 1) {
      die "Seed import failed. Invalid seed" unless $counter >= 5;
    }

    # difficulty 2, difficulty, pistol, weapom, grenade1, grenade2, util1, util2
    if ($state->{difficulty} >= 2) {
      die "Seed import failed. Invalid seed" unless $counter >= 7;
    }

    # difficulty 3, difficulty, pistol, wepaon, grenade1, grenade2, util1, util2, strat
    if ($state->{difficulty} >= 3) {
      die "Seed import failed. Invalid seed" unless $counter >= 8;
    }

    # hardcore setting 1
    #if ($state->{difficulty} >= 6) {
    # die "Seed import failed. Invalid seed" unless $counter >= 9;
    #}
    
    # hardcore setting 2
    #if ($state->{difficulty} >= 11) {
    # die "Seed import failed. Invalid seed" unless $counter >= 10;
    #}
    
    # hardcore setting 3
    #if ($state->{difficulty} >= 16 {
    # die "Seed import failed. Invalid seed" unless $counter >= 11;
    #}

    # hardcore setting 4
    #if ($state->{difficulty} >= 21) {
    # die "Seed import failed. Invalid seed" unless $counter >= 12;
    #}


    # how long does the seed have to be?
    $debugger->write("[IMPRT]: Topping off seed data");
    until ($counter == 13) {
      $seed_data{$counter} = 0;
      $counter++;
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return(%seed_data);
  }

  # perl needs this
  1;
}
