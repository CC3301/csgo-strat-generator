#!/usr/bin/perl
use strict;
use warnings;

use lib 'lib';
use Weapons;
use Grenades;
use Pistols;
use Utils;

################################################################################
# Main subroutine
################################################################################
sub Main() {
  
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # get difficulty
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my $difficulty = $ARGV[0] || 0;

  unless($difficulty =~ /^-?\d+$/) {
    die "Invalid difficulty";
  }

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # generate weapons 
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my %pistol = _generate_weapon_set('pistol');
  while(_check_for_free_choice($difficulty, %pistol)) {
    %pistol = _generate_weapon_set('pistol');
  }

  my %weapon = _generate_weapon_set('weapon');
  while(_check_for_free_choice($difficulty, %weapon)) {
    %weapon = _generate_weapon_set('weapon');
  }

  my %grenade1 = _generate_weapon_set('grenade1');
  while(_check_for_free_choice($difficulty, %grenade1)) {
    %grenade1 = _generate_weapon_set('grenade1');
  }

  my %grenade2 = _generate_weapon_set('grenade2');
  while(_check_for_free_choice($difficulty, %grenade2)) {
    %grenade2 = _generate_weapon_set('grenade2');
  }

  my %util1 = _generate_weapon_set('util1');
  while(_check_for_free_choice($difficulty, %util1)) {
    %util1 = _generate_weapon_set('util1');
  }

  my %util2 = _generate_weapon_set('util2');
  while(_check_for_free_choice($difficulty, %util2)) {
    %util2 = _generate_weapon_set('util2');
  }

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # generate hardcore settings
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #my %hardcore1 = Hardcore::GetHardcore($difficulty);

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # add all the costs together
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my $total_cost = $pistol{cost} + $grenade1{cost} + $grenade2{cost} + 
                   $weapon{cost} + $util1{cost} + $util2{cost};

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # add all the buy commands together
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my $command_string = "";
  my @buys = ($pistol{buy}, $grenade1{buy}, $grenade2{buy}, $weapon{buy},
              $util1{buy}, $util2{buy}); 
  foreach(@buys) {
    next if $_ eq "NONE";
    $command_string = $command_string . " buy $_;";
  }
   
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # print data
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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

  # print the rest of the stats
  print "===================================================================\n";
  print "\nDifficulty : $difficulty\n";
  print "Total Cost : $total_cost\$\n\n";
  print "Command: bind <key>\"$command_string\"\n";

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # return
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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
  if ($type eq 'pistol') {
    %item = Pistols::GetPistol();
  } elsif($type eq 'weapon') {
    %item = Weapons::GetWeapon();
  } elsif($type eq 'grenade1') {
    %item = Grenades::GetGrenade();
  } elsif($type eq 'grenade2') {
    %item = Grenades::GetGrenade();
  } elsif($type eq 'util1') {
    %item = Utils::GetUtil();
  } elsif($type eq 'util2') {
    %item = Utils::GetUtil();
  } else {
    die "Tried to generate unknown item type";
  }

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
    return 1;
  }

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # return data
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  return 0;

}
exit(Main());