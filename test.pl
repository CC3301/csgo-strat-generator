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
use Class::CSV;
use Data::Dumper;

use lib '.';

# get the amout of test in argv
my $test_count = shift @ARGV;
my @seeds;
my %results;

# init the result table
print "Initializing results table..\n";
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
print "Running tests..\n";
foreach my $difficulty (0..21) {
  print "\rProgress: " . int($difficulty/21 * 100) . "%";
  open(my $fh, '>', "data/config") or die "Cant create testing config";
    print $fh "export_seed:1\n";
    print $fh "difficulty:$difficulty\n";
  close $fh;
  foreach my $current_test (0..$test_count-1) {
    _run_test($difficulty);
  }
}

# calculate the results after running the tests
print "\nCalculating results..\n";
_calc_results();

# run test 
sub _run_test {

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

	print "Constructing result csv..\n";
	
	my @ids = ('difficulty');

  # pistol data
  foreach my $pistol_id (0..9) {
    push @ids, "pistol_id:$pistol_id";
  }
  # weapon data
  foreach my $weapon_id (0..19) {
    push @ids, "weapon_id:$weapon_id";
  }
  # grenade data
  foreach my $grenade_id (0..5) {
    push @ids, "grenade_id:$grenade_id";
  }
  # weapon data
  foreach my $util_id (0..4) {
    push @ids, "util_id:$util_id";
  }
  # weapon data
  foreach my $strat_id (0..13) {
    push @ids, "strat_id:$strat_id";
  }

  my $csv = Class::CSV->new(
		line_seperator => "\n",
    fields => \@ids,
  );

  # fill the csv object with data
  foreach my $difficulty (0..21) {
    
    $csv->add_line({
      difficulty     => $difficulty,
      "pistol_id:0"  => $results{$difficulty}{pistol_ids}{0}{count},
      "pistol_id:1"  => $results{$difficulty}{pistol_ids}{1}{count},
      "pistol_id:2"  => $results{$difficulty}{pistol_ids}{2}{count},
      "pistol_id:3"  => $results{$difficulty}{pistol_ids}{3}{count},
      "pistol_id:4"  => $results{$difficulty}{pistol_ids}{4}{count},
      "pistol_id:5"  => $results{$difficulty}{pistol_ids}{5}{count},
      "pistol_id:6"  => $results{$difficulty}{pistol_ids}{6}{count},
      "pistol_id:7"  => $results{$difficulty}{pistol_ids}{7}{count},
      "pistol_id:8"  => $results{$difficulty}{pistol_ids}{8}{count},
      "pistol_id:9"  => $results{$difficulty}{pistol_ids}{9}{count},
      "weapon_id:0"  => $results{$difficulty}{weapon_ids}{0}{count},
      "weapon_id:1"  => $results{$difficulty}{weapon_ids}{1}{count},
      "weapon_id:2"  => $results{$difficulty}{weapon_ids}{2}{count},
      "weapon_id:3"  => $results{$difficulty}{weapon_ids}{3}{count},
      "weapon_id:4"  => $results{$difficulty}{weapon_ids}{4}{count},
      "weapon_id:5"  => $results{$difficulty}{weapon_ids}{5}{count},
      "weapon_id:6"  => $results{$difficulty}{weapon_ids}{6}{count},
      "weapon_id:7"  => $results{$difficulty}{weapon_ids}{7}{count},
      "weapon_id:8"  => $results{$difficulty}{weapon_ids}{8}{count},
      "weapon_id:9"  => $results{$difficulty}{weapon_ids}{9}{count},
      "weapon_id:10" => $results{$difficulty}{weapon_ids}{10}{count},
      "weapon_id:11" => $results{$difficulty}{weapon_ids}{11}{count},
      "weapon_id:12" => $results{$difficulty}{weapon_ids}{12}{count},
      "weapon_id:13" => $results{$difficulty}{weapon_ids}{13}{count},
      "weapon_id:14" => $results{$difficulty}{weapon_ids}{14}{count},
      "weapon_id:15" => $results{$difficulty}{weapon_ids}{15}{count},
      "weapon_id:16" => $results{$difficulty}{weapon_ids}{16}{count},
      "weapon_id:17" => $results{$difficulty}{weapon_ids}{17}{count},
      "weapon_id:18" => $results{$difficulty}{weapon_ids}{18}{count},
      "weapon_id:19" => $results{$difficulty}{weapon_ids}{19}{count},
			"grenade_id:0" => $results{$difficulty}{grenade_ids}{0}{count},
			"grenade_id:1" => $results{$difficulty}{grenade_ids}{1}{count},
			"grenade_id:2" => $results{$difficulty}{grenade_ids}{2}{count},
			"grenade_id:3" => $results{$difficulty}{grenade_ids}{3}{count},
			"grenade_id:4" => $results{$difficulty}{grenade_ids}{4}{count},
			"grenade_id:5" => $results{$difficulty}{grenade_ids}{5}{count},
			"util_id:0"    => $results{$difficulty}{util_ids}{0}{count},
			"util_id:1"    => $results{$difficulty}{util_ids}{1}{count},
			"util_id:2"    => $results{$difficulty}{util_ids}{2}{count},
			"util_id:3"    => $results{$difficulty}{util_ids}{3}{count},
			"util_id:4"    => $results{$difficulty}{util_ids}{4}{count},
			"strat_id:0"   => $results{$difficulty}{strat_ids}{0}{count},
			"strat_id:1"   => $results{$difficulty}{strat_ids}{1}{count},
			"strat_id:2"   => $results{$difficulty}{strat_ids}{2}{count},
			"strat_id:3"   => $results{$difficulty}{strat_ids}{3}{count},
			"strat_id:4"   => $results{$difficulty}{strat_ids}{4}{count},
			"strat_id:5"   => $results{$difficulty}{strat_ids}{5}{count},
			"strat_id:6"   => $results{$difficulty}{strat_ids}{6}{count},
			"strat_id:7"   => $results{$difficulty}{strat_ids}{7}{count},
			"strat_id:8"   => $results{$difficulty}{strat_ids}{8}{count},
			"strat_id:9"   => $results{$difficulty}{strat_ids}{9}{count},
			"strat_id:10"  => $results{$difficulty}{strat_ids}{10}{count},
			"strat_id:11"  => $results{$difficulty}{strat_ids}{11}{count},
			"strat_id:12"  => $results{$difficulty}{strat_ids}{12}{count},
			"strat_id:13"  => $results{$difficulty}{strat_ids}{13}{count},
    });
  }
  # write the test output file
  open(my $fh, '>', "tests/test.csv") or die "Cannot open test result file for writing: $!";
    print $fh $csv->string();
  close $fh;
	print "All tests completed.\n";
}
