package Main {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules 
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;

  use lib 'lib/';

  use Util::Importer;

  use Feature::Hardcore;
  use Feature::Items;
  use Feature::Strats;

  ##############################################################################
  # Run subroutine
  ##############################################################################
  sub Run {
  
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get data passed to function 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $difficulty = shift;
    my $state = shift;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my %data;
    my (%pistol, %weapon, %grenade1, %grenade2, %util1, %util2, %strat, @hardcore);
    my %seed_data;
    
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # run all the generation code 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    $debugger->write("[MAIN] : Generating game-rule set..");
    $debugger->write("[MAIN] : Using difficulty: $difficulty..");
    $debugger->write("[MAIN] : Using os_type: $state->{os_type}");
    
    if ($state->{import_seed}) {
      
      # get the import data
      %seed_data = Util::Importer::Import($debugger, $state);
      $difficulty = $seed_data{0};
      $state->{difficulty} = $difficulty;
    
      # send a bunch of requests to the items module
      %pistol   = Feature::Items::GetItemByID($debugger, 'pistols',  $seed_data{1} );

      %weapon   = Feature::Items::GetItemByID($debugger, 'weapons',  $seed_data{2} );
  
      %grenade1 = Feature::Items::GetItemByID($debugger, 'grenades', $seed_data{3});
      %grenade2 = Feature::Items::GetItemByID($debugger, 'grenades', $seed_data{4});

      %util1    = Feature::Items::GetItemByID($debugger, 'utils',    $seed_data{5});
      %util2    = Feature::Items::GetItemByID($debugger, 'utils',    $seed_data{6});

      # generate strat
      %strat = Feature::Strats::GetStrat($debugger, $difficulty, $seed_data{7}, $state);

    } else {
    
      # generate a pistol
      %pistol = Feature::Items::GetItem($debugger, 'pistols');
      while(_check_for_free_choice($debugger, $difficulty, %pistol)) {
        %pistol = Feature::Items::GetItem($debugger, 'pistols');
      }

      # generate a weapon
      %weapon = Feature::Items::GetItem($debugger, 'weapons');
      while(_check_for_free_choice($debugger, $difficulty, %weapon)) {
        %weapon = Feature::Items::GetItem($debugger, 'weapons');
      }

      # generate a grenade set
      %grenade1 = Feature::Items::GetItem($debugger, 'grenades');
      %grenade2 = Feature::Items::GetItem($debugger, 'grenades');
      while(_check_for_free_choice($debugger, $difficulty, %grenade1)) {
        %grenade1 = Feature::Items::GetItem($debugger, 'grenades');
      }
      while(_check_for_free_choice($debugger, $difficulty, %grenade2) || _check_for_duplicate($debugger, \%grenade1, \%grenade2)) {
        %grenade2 = Feature::Items::GetItem($debugger, 'grenades');
      }
  
      # generate a util set
      %util1 = Feature::Items::GetItem($debugger, 'utils');
      %util2 = Feature::Items::GetItem($debugger, 'utils');
      while(_check_for_free_choice($debugger, $difficulty, %util1)) {
        %util1 = Feature::Items::GetItem($debugger, 'utils');
      }
      while(_check_for_free_choice($debugger, $difficulty, %util2) || _check_for_duplicate($debugger, \%util1, \%util2)) {
        %util2 = Feature::Items::GetItem($debugger, 'utils');
      }
      if($util1{buy} eq 'vesthelm') {
        while($util2{buy} eq 'vest') {
          %util2 = Feature::Items::GetItem($debugger, 'utils');
          if(_check_for_free_choice($debugger, $difficulty, %util2) || _check_for_duplicate($debugger, \%util1, \%util2)) {
            $util2{buy} = 'vest';
          }
        }
      }
      if($util2{buy} eq 'vesthelm') {
        while($util1{buy} eq 'vest') {
          %util1 = Feature::Items::GetItem($debugger, 'utils');
          if(_check_for_free_choice($debugger, $difficulty, %util1) || _check_for_duplicate($debugger, \%util1, \%util2)) {
            $util1{buy} = 'vest';
          }
        }
      }
  
      # generate strat
      %strat = Feature::Strats::GetStrat($debugger, $difficulty, '', $state);
  
      # generate hardcore settings
      @hardcore = Feature::Hardcore::GetHardcore($debugger, $difficulty);

    }

    $debugger->write("[MAIN] : Completed item, strat and hardcore generation.");
    
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # modify data by settings 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    if ($state->{disable}{pistol}) {
      $pistol{name} = 'Free choice';
      $pistol{cost} = 0;
      $pistol{buy} = 'NULL';
    }
    if ($state->{disable}{weapon}) {
      $weapon{name} = 'Free choice';
      $weapon{cost} = 0;
      $weapon{buy} = 'NULL';
    }
    if ($state->{disable}{grenades}) {
      $grenade1{name} = 'Free choice';
      $grenade2{name} = 'Free choice';
      $grenade1{cost} = 0;
      $grenade2{cost} = 0;
      $grenade1{buy} = 'NULL';
      $grenade2{buy} = 'NULL';
    }
    if ($state->{disable}{utils}) {
      $util1{name} = 'Free choice';
      $util2{name} = 'Free choice';
      $util1{cost} = 0;
      $util2{cost} = 0;
      $util1{buy} = 'NULL';
      $util2{buy} = 'NULL';
    }
    if ($state->{disable}{hardcore}) {
      my $hardcore_counter = 0;
      foreach(@hardcore) {
        $hardcore[$hardcore_counter] = 'None';
        $hardcore_counter++;
      }
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # process all the data we got 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    $debugger->write("[MAIN] : Processing cost and buy command data..");

    # split into ct and t prices
    ($pistol{cost_ct},   $pistol{cost_t})   = split '-', $pistol{cost};
    ($weapon{cost_ct},   $weapon{cost_t})   = split '-', $weapon{cost};
    ($grenade1{cost_ct}, $grenade1{cost_t}) = split '-', $grenade1{cost};
    ($grenade2{cost_ct}, $grenade2{cost_t}) = split '-', $grenade2{cost};
    ($util1{cost_ct},    $util1{cost_t})    = split '-', $util1{cost};
    ($util2{cost_ct},    $util2{cost_t})    = split '-', $util2{cost};

    # calculate the total cost
    if($difficulty >= 0) {
      $data{total_cost_ct} = $pistol{cost_ct} + $weapon{cost_ct};
      $data{total_cost_t}  = $pistol{cost_t}  + $weapon{cost_t};
    }
    if($difficulty >= 1) {
      $data{total_cost_ct} = $data{total_cost_ct} + $grenade1{cost_ct} + $grenade2{cost_ct};
      $data{total_cost_t}  = $data{total_cost_t}  + $grenade1{cost_t}  + $grenade2{cost_t};
    }
    if($difficulty >= 2) {
      $data{total_cost_ct} = $data{total_cost_ct} + $util1{cost_ct} + $util2{cost_ct};
      $data{total_cost_t}  = $data{total_cost_t}  + $util1{cost_t}  + $util2{cost_t};
    }

    # build the command string for buying all the items
    $data{command_string} = '';
    my @buys = ($pistol{buy}, $util1{buy}, $util2{buy}, $grenade1{buy}, $grenade2{buy},
                $weapon{buy}
    );
    foreach(@buys) {
      next if $_ eq 'NONE' || $_ eq 'NULL';
      $data{command_string} = $data{command_string} . "buy $_; ";
    }

    # change command string to 'unbind all' when the user sets every disable flag available
    if ($state->{disable}->{pistol} && $state->{disable}->{weapon} && $state->{disable}->{grenades} && $state->{disable}->{utils} && 
        $state->{disable}->{hardcore} && $state->{disable}->{strats} ){

          $data{command_string} = 'unbind all';
    }

    my $hardcore_string = join ';', @hardcore;

    $debugger->write("[MAIN] : Finished process cost and buy command data.");

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # construct return data hash
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    $data{pistol_name}   = $pistol{name};
    $data{grenade_names} = $grenade1{name} . ';' . $grenade2{name};
    $data{util_names}    = $util1{name} . ';' . $util2{name};
    $data{weapon_name}   = $weapon{name};
    $data{strat_name}    = $strat{name};
    $data{strat_desc}    = $strat{desc};
    $data{hardcore}      = $hardcore_string;

    $data{pistol_buy}   = $pistol{buy};
    $data{grenade_buys} = $grenade1{buy} . ';' . $grenade2{buy};
    $data{util_buys}    = $util1{buy} . ';' . $util2{buy};
    $data{weapon_buy}   = $weapon{buy};

    $data{pistol_id}    = $pistol{id};
    $data{weapon_id}    = $weapon{id};
    $data{grenade_ids}  = $grenade1{id} . ';' . $grenade2{id};
    $data{util_ids}     = $util1{id} . ';' . $util2{id};
    $data{strat_id}     = $strat{id};


    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    if (%data) {
      return($difficulty, %data);
    } else {
      die("no data generated");
    }

  }
    
  ##############################################################################
  # _check_for_free_choice subroutine
  ##############################################################################
  sub _check_for_free_choice {
  
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to the function
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $difficulty = shift;
    my %item = @_;
    
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return when the difficulty is too low
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return(0) if $difficulty < 3;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # check each dataset for free choice
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    if ($item{buy} eq "NONE") {
      $debugger->write("[MAIN] : Found free choice, running difficulty $difficulty. Regenerating");
      return 1;
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return 0;
  }

  ##############################################################################
  # _check_for_duplicate subroutine 
  ##############################################################################
  sub _check_for_duplicate {
  
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to the function
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $item1 = shift;
    my $item2 = shift;
  
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # check each dataset for duplicates 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    if ($item1->{buy} eq $item2->{buy}) {
      $debugger->write("[MAIN] : Found duplicate item (" . $item1->{buy} . "). Regenerating.");
      return 1;
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return 0;
  }

  ### perl needs this
  1;
}
