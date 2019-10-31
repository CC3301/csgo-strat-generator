package Util::Exporter {
  
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;
 
  use lib 'lib/';
  #use Util::Tools;
  use Util::Random;

  #############################################################################
  # Export subroutine
  #############################################################################
  sub Export {

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get data passed to the function
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $data  = shift;
    my $state = shift;

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/!?][}{+~*%#@';
    my @chars = split //, $chars;
    @chars = _shuffle($debugger, \@chars);

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # transform some vars into a more readable format 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $difficulty = $state->{difficulty};
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # write output 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    if ($state->{write_file}) {
      open(my $fh, '>', 'export.txt');
     
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
        if ($data->{total_cost_ct} == $data->{total_cost_t}) {
          print $fh "Total Cost   : $data->{total_cost_ct}\$\n\n";
        } else {
          print $fh "Total Cost T : $data->{total_cost_t}\$\n";
          print $fh "Total Cost CT: $data->{total_cost_ct}\$\n\n";
        }
        print $fh "Command:\n";
        print $fh "\tbind $state->{default_key} \"$data->{command_string}\"\n";
        print $fh "\n";
        print $fh "===========================================================\n";

      close $fh;
    }

    # write to csgo config directory
    if ($state->{write_csgo}) { 
      if ($state->{os_type} eq 'windows') {

        my $dir = "C:/'Program Files (x86)'/Steam/userdata/*";
        my @userdata_dir = glob ($dir);

        foreach (@userdata_dir) {
          open(my $fh1, '>', "$_/730/local/cfg/csgo-strat-gen.cfg") or warn "failed to write direct-apply config: $!\n for cfg_dir: $_";
            print $fh1 "bind $state->{default_key} \"$data->{command_string}\"\n";
          close $fh1;
        }
      } else {
        $debugger->write("[EXPRT]: This feature is not available on $state->{os_type} right now.");
        warn "Cannot write to csgo config directory, feature not supported for $state->{os_type}";
      }
    }

    # if the --export-html flag is set, export html template for use in csgo-ban time manager
    if ($state->{export_html}) {

      # get the seed
      my $seed = _generate_seed($debugger, $data, $state, \@chars);

      open(my $fh, '>', "strat-gen-output.tmpl") or die "Failed to write html output file";

        # begin
        print $fh "<html>\n";
        print $fh "\t<head>\n";
        print $fh "\t\t<meta charset=\"utf-8\" />\n";
        print $fh "\t</head>\n";
        print $fh "\t<body>\n";
        print $fh "\t\t<div class=\"strat-gen-output\">\n";
        print $fh "\t\t\t<table>\n";

        # Seed
        print $fh "\t\t\t\t<tr>\n";
        print $fh "\t\t\t\t\t<td>\n";
        print $fh "\t\t\t\t\t\tSeed\n";
        print $fh "\t\t\t\t\t</td>\n";
        print $fh "\t\t\t\t\t<td>\n";
        print $fh "\t\t\t\t\t\t$seed\n";
        print $fh "\t\t\t\t\t</td>\n";
        print $fh "\t\t\t\t</tr>\n";

        # Pistols
        if ($difficulty >= 0 && (! $state->{disable}->{pistol} || $state->{display_disabled})) {
          print $fh "\t\t\t\t<tr>\n";
          print $fh "\t\t\t\t\t<td>\n";
          print $fh "\t\t\t\t\t\tPistol\n";
          print $fh "\t\t\t\t\t</td>\n";
          print $fh "\t\t\t\t\t<td>\n";
          print $fh "\t\t\t\t\t\t$data->{pistol_name}\n";
          print $fh "\t\t\t\t\t</td>\n";
          print $fh "\t\t\t\t</tr>\n";
        }

        # Weapon
        if ($difficulty >= 0 && (! $state->{disable}->{weapon} || $state->{display_disabled})) {
          print $fh "\t\t\t\t<tr>\n";
          print $fh "\t\t\t\t\t<td>\n";
          print $fh "\t\t\t\t\t\tWeapon\n";
          print $fh "\t\t\t\t\t</td>\n";
          print $fh "\t\t\t\t\t<td>\n";
          print $fh "\t\t\t\t\t\t$data->{weapon_name}\n";
          print $fh "\t\t\t\t\t</td>\n";
          print $fh "\t\t\t\t</tr>\n";
        }

        # nades
        if ($difficulty >= 1 && (! $state->{disable}->{grenades} || $state->{display_disabled})) {
          print $fh "\t\t\t\t<tr>\n";
          print $fh "\t\t\t\t\t<td>\n";
          print $fh "\t\t\t\t\t\tGrenade(s)\n";
          print $fh "\t\t\t\t\t</td>\n";
          print $fh "\t\t\t\t\t<td>\n";
          print $fh "\t\t\t\t\t\t";
          foreach(split ';', $data->{grenade_names}){
            print $fh "$_, ";
          }
          print $fh "\n";
          print $fh "\t\t\t\t\t</td>\n";
          print $fh "\t\t\t\t</tr>\n";
        }

        # Utils
        if ($difficulty >= 2 && (! $state->{disable}->{utils} || $state->{display_disabled})) {
          print $fh "\t\t\t\t<tr>\n";
          print $fh "\t\t\t\t\t<td>\n";
          print $fh "\t\t\t\t\t\tUtil(s)\n";
          print $fh "\t\t\t\t\t</td>\n";
          print $fh "\t\t\t\t\t<td>\n";
          print $fh "\t\t\t\t\t\t";
          foreach(split ';', $data->{util_names}){
            print $fh "$_, ";
          }
          print $fh "\n";
          print $fh "\t\t\t\t\t</td>\n";
          print $fh "\t\t\t\t</tr>\n";
        }

        # hardcore
        if ($difficulty >= 6 && (! $state->{disable}->{hardcore} || $state->{display_disabled})) {
          print $fh "\t\t\t\t<tr>\n";
          print $fh "\t\t\t\t\t<td>\n";
          print $fh "\t\t\t\t\t\tHardcore Setting(s)\n";
          print $fh "\t\t\t\t\t</td>\n";
          print $fh "\t\t\t\t\t<td>\n";
          print $fh "\t\t\t\t\t\t";
          foreach(split ';', $data->{hardcore}){
            print $fh "$_, ";
          }
          print $fh "\n";
          print $fh "\t\t\t\t\t</td>\n";
          print $fh "\t\t\t\t</tr>\n";
        }


        if ($difficulty >= 3 && (! $state->{disable}->{strats} || $state->{display_disabled})) {
          print $fh "\t\t\t\t<tr>\n";
          print $fh "\t\t\t\t\t<td>\n";
          print $fh "\t\t\t\t\t\tStrat\n";
          print $fh "\t\t\t\t\t</td>\n";
          print $fh "\t\t\t\t\t<td>\n";
          print $fh "\t\t\t\t\t\t$data->{strat_name}: <br/>";
          foreach(split ';', $data->{strat_desc}){
            print $fh "$_<br/>";
          }
          print $fh "\n";
          print $fh "\t\t\t\t\t</td>\n";
          print $fh "\t\t\t\t</tr>\n";
        }

        # Difficulty
        print $fh "\t\t\t\t<tr>\n";
        print $fh "\t\t\t\t\t<td>\n";
        print $fh "\t\t\t\t\t\tDifficulty\n";
        print $fh "\t\t\t\t\t</td>\n";
        print $fh "\t\t\t\t\t<td>\n";
        print $fh "\t\t\t\t\t\t$difficulty\n";
        print $fh "\t\t\t\t\t</td>\n";
        print $fh "\t\t\t\t</tr>\n";

        # End
        print $fh "\t\t\t</table>\n";
        print $fh "\t\t</div>\n";
        print $fh "\t</body>\n";
        print $fh "</html>\n";

      close $fh;

    }

    # if the --export flag is set, export a seed
    if ($state->{export_seed}) {
      my ($seed) = _generate_seed($debugger, $data, $state, \@chars);
      chomp $seed;
      print "\n==================================================================\n";
      print "Seed: '$seed'\n";
      print "==================================================================\n\n";
    }

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return();

  }

  ##############################################################################
  # _generate_seed subroutine
  ##############################################################################
  sub _generate_seed { 
  
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to function 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $data = shift;
    my $state = shift;
    my $chars = shift;

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $counter = 0;
    my $char_count = @$chars;

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # generate seed 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $seed = "@$chars[Util::Random::GetRandom($debugger, $char_count)]$state->{difficulty}";

    # on difficulty 0, we have pistols and weapons, each need to be individually checked
    if ($state->{difficulty} >= 0 && (! $state->{disable}->{pistols} || $state->{display_disabled})) {
      $seed = $seed . "@$chars[Util::Random::GetRandom($debugger, $char_count)]$data->{pistol_id}";
    }
    if ($state->{difficulty} >= 0 && (! $state->{disable}->{weapons} || $state->{display_disabled})) {
      $seed = $seed . "@$chars[Util::Random::GetRandom($debugger, $char_count)]$data->{weapon_id}";
    }
    
    # on difficulty 1, we have grenades
    if ($state->{difficulty} >= 1 && (! $state->{disabled}->{grenades} || $state->{display_disabled})) {
      $counter = 0;
      my @grenade_ids = split ';', $data->{grenade_ids};
      foreach(@grenade_ids) {
        $seed = $seed . "@$chars[Util::Random::GetRandom($debugger, $char_count)]$_";
        $counter++;
      }
    }

    # on difficulty 2, we have utilities
    if ($state->{difficulty} >= 2 && (! $state->{disabled}->{utils} || $state->{display_disabled})) {
      $counter = 0;
      my @util_ids = split ';', $data->{util_ids};
      foreach(@util_ids) {
        $seed = $seed . "@$chars[Util::Random::GetRandom($debugger, $char_count)]$_";
        $counter++;
      }
    }

    # on difficulty 3, the only difference is if we have a strat or not. 
    if ($state->{difficulty} >= 3 && (! $state->{disable}->{strats} || $state->{display_disabled})) {
      $seed = $seed . "@$chars[Util::Random::GetRandom($debugger, $char_count)]$data->{strat_id}";
    }
    
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return seed 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return($seed);
  }

  ##############################################################################
  # _shuffle subroutine
  ##############################################################################
  sub _shuffle {
 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to the function
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $deck = shift;
 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $i = @$deck;
 
    # randomize the array
    while($i--) {
      my $j = Util::Random::GetRandom($debugger, $i+1);
      @$deck[$i,$j] = @$deck[$j,$i];
    }   
 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return(@$deck);
  }

  # perl needs this
  1;
}
