package Util::Exporter {
  
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;
  
  use lib 'lib/';
  use Util::Debug;

  my $DEBUG_STATE = 0;

  #############################################################################
  # Export subroutine
  #############################################################################
  sub Export {

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get data passed to the function
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $data  = shift;
    my $state = shift;

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # transform some vars into a more readable format 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $difficulty = $state->{difficulty};
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # write output 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    open(my $fh, '>', 'data/export.txt');
    
      print $fh "csgo-strat-generator exported output\n";
      print $fh "===========================================================\n";
      if ($difficulty >= 0 && (! $state->{disable}->{pistol} || $state->{display_disabled})) {
        print $fh "Pistol: $data->{pistol_name}\n";
      }
      if ($difficulty >= 0 && (! $state->{disable}->{weapon} || $state->{display_disabled})) {
        print $fh "Weapon: $data->{weapon_name}\n";
      }
      if ($difficulty >= 1 && (! $state->{disable}->{grenades} || $state->{display_disabled})) {
        print $fh "\n";
        print $fh "Grenades:\n";
        foreach(split ';', $data->{grenade_names}){
          print $fh "\t- $_\n";
        }
      }
      if ($difficulty >= 2 && (! $state->{disable}->{utils} || $state->{display_disabled})) {
        print $fh "\n";
        print $fh "Utilities:\n";
        foreach(split ';', $data->{util_names}){
          print $fh "\t- $_\n";
        }
      }
      if ($difficulty >= 6 && (! $state->{disable}->{hardcore} || $state->{display_disabled})) { 
        print $fh "\n";
        print $fh "Hardcore settings:\n";
        foreach(split ';', $data->{hardcore}){
          print $fh "\t- $_\n";
        }
      }
      if ($difficulty >= 3 && (! $state->{disable}->{strats} || $state->{display_disabled})) {
        print $fh "\n";
        print $fh "Strat: $data->{strat_name}\n";
        foreach(split ';', $data->{strat_desc}){
          print $fh "\t$_\n";
        }
      }
      print $fh "\n";
      print $fh "Difficulty: $difficulty\n";
      print $fh "Total Cost: $data->{total_cost}\$\n";
      print $fh "Command:\n";
      print $fh "\tbind $state->{default_key} \"$data->{command_string}\"\n";
      print $fh "\n";
      print $fh "===========================================================\n";

    close $fh;
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return();

  }

  # perl needs this
  1;
}
