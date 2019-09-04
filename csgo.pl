#!/usr/bin/perl
use strict;
use warnings;

use lib 'lib';
use Weapons;
use Grenades;
use Pistols;
use Utils;

Weapons::GetWeapon();
print "\n";
Grenades::GetGrenade();
print "\n";
Pistols::GetPistol();
print "\n";
Utils::GetUtil();
Utils::GetUtil();
