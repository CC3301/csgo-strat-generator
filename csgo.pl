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
  # generate weapons
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my %pistol   = Pistols::GetPistol();
  my %grenade1 = Grenades::GetGrenade();
  my %grenade2 = Grenades::GetGrenade();
  my %weapon   = Weapons::GetWeapon();
  my %util1    = Utils::GetUtil();
  my %util2    = Utils::GetUtil();
  
  # test print
  print $grenade1{name} . "\n";
  print $grenade1{buy}  . "\n";
  print $grenade1{cost} . "\n";

  # add all the costs together
  my $total_cost = 0;
  my @costs = ( $pistol{cost}, $grenade1{cost}, $grenade2{cost}, $weapon{cost},
                $util1{cost}, $util2{cost} );
  foreach(@costs) {
    my $total_cost = $total_cost + $_; 
  }

  
  
}

Main();