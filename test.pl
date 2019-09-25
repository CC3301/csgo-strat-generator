#
# THIS FILE PROVIDES AUTOMATIC TESTS, NOT INCLUDED IN .zip BUILD
# 
#
#
#
#

use strict;
use warnings;
use Capture::Tiny ':all';
use Data::Dumper;

use lib '.';

# get the amout of test in argv
my $test_count = 200;
my @seeds;
my %results;

# init the result table
foreach my $difficulty_out (0..21) {
  $results{$difficulty_out}{difficulty} = 0;

  # pistols
  foreach my $pistol_id_out (0..9) {
    $results{$difficulty_out}{pistol_ids}{$pistol_id_out}{count} = 0;
  }
  # weapons
  foreach my $weapon_id_out (0..19) {
    $results{$difficulty_out}{weapon_ids}{$weapon_id_out}{count} = 0;
  }
  # grenades
  foreach my $grenade_id_out (0..5) {
    $results{$difficulty_out}{grenade_ids}{$grenade_id_out}{count} = 0;
  }
  # utils
  foreach my $util_id_out (0..4) {
    $results{$difficulty_out}{util_ids}{$util_id_out}{count} = 0;
  }
  # strats
  foreach my $strat_id_out (0..13) {
    $results{$difficulty_out}{strat_ids}{$strat_id_out}{count} = 0;
  }
}



# run the tests as requested
foreach my $curren_test (0..$test_count-1) {
  foreach(0..21) {
    print "\rCurrent Test: $curren_test/$test_count\tSubtest: $_/21";
    _run_test($_);
  }
}

# calculate the results after running the tests
_calc_results();

# run test 
sub _run_test {

  my $difficulty = shift;

  open(my $fh, '>', "data/config") or die "Cant create testing config";
    print $fh "export_seed:1\n";
    print $fh "difficulty:$difficulty\n";
  close $fh;
  
  my $cmd_output;
  $cmd_output = capture {
    eval {
      do "csgo.pl";
    };
  };

  my @output = (split 'Seed: ', $cmd_output);
  @output = split "\n", $output[1];
  @output = split "'", $output[0];

  push @seeds, $output[1];

}

# calculate results
sub _calc_results {

  my $counter = 0;
  my %seed_data;

  foreach(@seeds) {

    # get seed data
    %seed_data = _parse_seed($_);

    # put in results table
    $results{$seed_data{0}}{difficulty}++; # difficulty

    $results{$seed_data{0}}{pistol_ids}{$seed_data{1}}{count}++; # pistol
    $results{$seed_data{0}}{weapon_ids}{$seed_data{2}}{count}++; # weapon

    $results{$seed_data{0}}{grenade_ids}{$seed_data{3}}{count}++; # grenade 1
    $results{$seed_data{0}}{grenade_ids}{$seed_data{4}}{count}++; # grenade 2

    $results{$seed_data{0}}{util_ids}{$seed_data{5}}{count}++; # util 1
    $results{$seed_data{0}}{util_ids}{$seed_data{6}}{count}++; # util 2

    $results{$seed_data{0}}{strat_ids}{$seed_data{7}}{count}++; # strat

    $results{$seed_data{0}}{$seed_data{8}}{count}++;
    $results{$seed_data{0}}{$seed_data{9}}{count}++;
    $results{$seed_data{0}}{$seed_data{10}}{count}++;
    $results{$seed_data{0}}{$seed_data{11}}{count}++;
    $results{$seed_data{0}}{$seed_data{12}}{count}++;

    # increment the counter
    $counter++;
  }

  foreach my $difficulty (0..21) {

    # pistol ids
    foreach my $pistol_id (0..9) {
      if ($seed_data{1} == $pistol_id) {
        $results{$difficulty}{pistol_ids}{$pistol_id}{count}++;
      }
    }
    # weapon ids
    foreach my $weapon_id (0..19) {
      if ($seed_data{1} == $weapon_id) {
        $results{$difficulty}{weapon_ids}{$weapon_id}{count}++;
      }
    } 
  }

  # print the results
  _print_results();

}

# parse seed
sub _parse_seed {

  my $key_counter = -1;
  my %seed_data;
  my $value = '';

  my @seed = split //, $_[0];

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

  # fill the rest of the output with 0's
  until ($key_counter == 13) {
    $seed_data{$key_counter} = 0;
    $key_counter++;
  }

  # return the seed data
  return(%seed_data);
}

# print some results
sub _print_results {

  my $csv;
  my @ids = ('difficulty');

  foreach my $difficulty (0..21) {
    print "Diffculty $difficulty used $results{$difficulty}{difficulty} times\n";

    # pistol data
    foreach my $pistol_id (0..9) {
      print "\tPistol id $pistol_id appears $results{$difficulty}{pistol_ids}{$pistol_id}{count} times\n";
      push @ids, "pistol_id:$pistol_id";
    }
    print "\n";
    # weapon data
    foreach my $weapon_id (0..19) {
      print "\tWeapon id $weapon_id appears $results{$difficulty}{weapon_ids}{$weapon_id}{count} times\n";
      push @ids, "weapon_id:$weapon_id";
    }
    print "\n";
    # grenade data
    foreach my $grenade_id (0..5) {
      print "\tGrenade id $grenade_id appears $results{$difficulty}{grenade_ids}{$grenade_id}{count} times\n";
      push @ids, "grenade_id:$grenade_id";
    }
    print "\n";
    # weapon data
    foreach my $util_id (0..4) {
      print "\tUtil id $util_id appears $results{$difficulty}{util_ids}{$util_id}{count} times\n";
      push @ids, "strat_id:$util_id";
    }
    print "\n";
    # weapon data
    foreach my $strat_id (0..13) {
      print "\tStrat id $strat_id appears $results{$difficulty}{strat_ids}{$strat_id}{count} times\n";
      push @ids, "strat_id:$strat_id";
    }
    print "\n";
  }

}