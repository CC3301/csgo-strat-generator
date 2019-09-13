#!/usr/bin/perl
use strict;
use warnings;

use lib 'lib';
use Items;
use Strats;
use Hardcore;
use Debug;

$|--;

################################################################################
# Main subroutine
################################################################################
sub Main() {
  
  # initialize the debug output
  Debug::Debug("Starting csgo strat gen..");

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # get difficulty
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my $difficulty = $ARGV[0] || 0;

  unless($difficulty =~ /^-?\d+$/) {
    die "Invalid difficulty";
  }

  Debug::Debug("Using difficulty: $difficulty");

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # generate weapons 
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  # generate pistol and check for free choice
  my %pistol = _generate_weapon_set('pistols');
  while(_check_for_free_choice($difficulty, %pistol)) {
    %pistol = _generate_weapon_set('pistols');
  }
  
  # generate weapon and check for free choice
  my %weapon = _generate_weapon_set('weapons');
  while(_check_for_free_choice($difficulty, %weapon)) {
    %weapon = _generate_weapon_set('weapons');
  }

  # generate grenade1 and check for free choice
  my %grenade1 = _generate_weapon_set('grenades');
  while(_check_for_free_choice($difficulty, %grenade1)) {
    %grenade1 = _generate_weapon_set('grenades');
  }

  # generate grenade2 and check for free choice
  my %grenade2 = _generate_weapon_set('grenades');
  while(_check_for_free_choice($difficulty, %grenade2) || _check_for_duplicate(\%grenade1, \%grenade2)) {
    %grenade2 = _generate_weapon_set('grenades');
  }

  # generate util2 and check for free choice
  my %util1 = _generate_weapon_set('utils');
  while(_check_for_free_choice($difficulty, %util1)) {
    %util1 = _generate_weapon_set('utils');
  }

  # generate util2 and check for free choice
  my %util2 = _generate_weapon_set('utils');
  while(_check_for_free_choice($difficulty, %util2) || _check_for_duplicate(\%util1, \%util2)) {
    %util2 = _generate_weapon_set('utils');
  }

  # generate strat
  my %strat = Strats::GetStrat($difficulty);

  # generate hardcore settings
  my @hardcore_settings = Hardcore::GetHardcore($difficulty);

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # generate hardcore settings
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #my %hardcore1 = Hardcore::GetHardcore($difficulty);

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # add all the costs together
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my $total_cost = $pistol{cost} + $grenade1{cost} + $grenade2{cost} + 
                   $weapon{cost} + $util1{cost} + $util2{cost};
  Debug::Debug("Total cost of all items: $total_cost\$");

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # add all the buy commands together
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my $command_string = "";
  my @buys = ($pistol{buy}, $grenade1{buy}, $grenade2{buy}, $weapon{buy},
              $util1{buy}, $util2{buy}); 

  Debug::Debug("Constructing the buy command");
  foreach(@buys) {
    next if $_ eq "NONE";
    $command_string = $command_string . " buy $_;";
  }
  Debug::Debug("Buy command: $command_string");
   
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # print data
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Debug::Debug("Priting output");
  print "CSGO strat-generator output:\n\n";
  print "===================================================================\n";
  
  if ($difficulty >= 0) {
    print "Pistol to use   : " . $pistol{name}   . "\n";
    print "Weapon to use   : " . $weapon{name}   . "\n";
  }
  if ($difficulty >= 1) {
    print "Grenades to use : " . $grenade1{name} . ", " . $grenade2{name} . "\n";
  }
  if ($difficulty >= 2) {
    print "Utilities to use: " . $util1{name} . ", " . $util2{name} . "\n";
  }
  if ($difficulty >= 6) {
    print "\n";
    print "Hardcore settings: \n";
    foreach(@hardcore_settings) {
      print "\t- $_\n";
    }
  }
  if ($difficulty >= 3) {
    print "\n";
    print "Strat: " . $strat{name} . "\n";
    print "Description:\n";
    foreach(split ';', $strat{desc}) {
      print "\t$_\n";
    }
    print "\nNOTE: Hardcore settings overwrite strats.\n";
  }

  # print the rest of the stats
  print "===================================================================\n";
  print "\nDifficulty : $difficulty\n";
  print "Total Cost : $total_cost\$\n\n";
  print "Command: bind <key>\"$command_string\"\n";

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # return
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Debug::Debug("csgo strat gen complete.");
  Debug::Debug("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" .
  "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n", 1);
  return(0);
  
}

################################################################################
# _generate_weapon_set subroutine
################################################################################
sub _generate_weapon_set {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # get vars passed to the function
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my $type = shift;

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # other vars
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my %item;

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # generate datasets
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  %item = Items::GetItem($type);

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # return data
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  return(%item);

}

################################################################################
# _check_for_free_choice subroutine
################################################################################
sub _check_for_free_choice {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # get vars passed to the function
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my $difficulty = shift;
  my %item = @_;
  
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # return when the difficulty is too low
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  return(0) if $difficulty < 3;

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # check each dataset for free choice
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  if ($item{buy} eq "NONE") {
    Debug::Debug("Found free choice, running difficulty $difficulty. Regenerating");
    return 1;
  }

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # return data
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  return 0;

}

################################################################################
# _check_for_duplicate subroutine 
################################################################################
sub _check_for_duplicate {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # get vars passed to the function
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my $item1 = shift;
  my $item2 = shift;

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # check each dataset for duplicates 
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  if ($item1->{buy} eq $item2->{buy}) {
    Debug::Debug("Found duplicate item (" . $item1->{buy} . "). Regenerating.");
    return 1;
  }

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # return data
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  return 0;

}

################################################################################
# Main subroutine call 
################################################################################
exit(Main());
