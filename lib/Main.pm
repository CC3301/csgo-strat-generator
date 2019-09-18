package Main {

  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules 
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;

  use lib 'lib/';
  use Util::Debug;

  use Feature::Hardcore;
  use Feature::Items;
  use Feature::Strats;

  my $DEBUG_STATE = 0;

  #############################################################################
  # Run subroutine
  #############################################################################
  sub Run {
  
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get data passed to function 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $difficulty = shift;
    my %state = @_;

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # reserve namespace for a return hash 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my %data;

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # run all the generation code 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    _local_debug("[MAIN] : Generating game-rule set..");
    _local_debug("[MAIN] : Using difficulty: $difficulty..");
    
    # generate a pistol
    my %pistol = Feature::Items::GetItem('pistols');
    while(_check_for_free_choice($difficulty, %pistol)) {
      %pistol = Feature::Items::GetItem('pistols');
    }

    # generate a weapon
    my %weapon = Feature::Items::GetItem('weapons');
    while(_check_for_free_choice($difficulty, %weapon)) {
      %weapon = Feature::Items::GetItem('weapons');
    }

    # generate a grenade set
    my %grenade1 = Feature::Items::GetItem('grenades');
    my %grenade2 = Feature::Items::GetItem('grenades');
    while(_check_for_free_choice($difficulty, %grenade1)) {
      %grenade1 = Feature::Items::GetItem('grenades');
    }
    while(_check_for_free_choice($difficulty, %grenade2) || _check_for_duplicate(\%grenade1, \%grenade2)) {
      %grenade2 = Feature::Items::GetItem('grenades');
    }

    # generate a util set
    my %util1 = Feature::Items::GetItem('utils');
    my %util2 = Feature::Items::GetItem('utils');
    while(_check_for_free_choice($difficulty, %util1)) {
      %util1 = Feature::Items::GetItem('utils');
    }
    while(_check_for_free_choice($difficulty, %util2) || _check_for_duplicate(\%util1, \%util2)) {
      %util2 = Feature::Items::GetItem('utils');
    }
    if($util1{buy} eq 'vesthelm') {
      while($util2{buy} eq 'vest') {
        %util2 = Feature::Items::GetItem('utils');
        if(_check_for_free_choice($difficulty, %util2) || _check_for_duplicate(\%util1, \%util2)) {
          $util2{buy} = 'vest';
        }
      }
    }
    if($util2{buy} eq 'vesthelm') {
      while($util1{buy} eq 'vest') {
        %util1 = Feature::Items::GetItem('utils');
        if(_check_for_free_choice($difficulty, %util1) || _check_for_duplicate(\%util1, \%util2)) {
          $util1{buy} = 'vest';
        }
      }
    }

    # generate strat
    my %strat = Feature::Strats::GetStrat($difficulty);

    # generate hardcore settings
    my @hardcore = Feature::Hardcore::GetHardcore($difficulty);

    _local_debug("[MAIN] : Completed item, strat and hardcore generation.");
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # modify data by settings 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    if ($state{disable}{pistol}) {
      $pistol{name} = 'Free choice';
      $pistol{cost} = 0;
    }
    if ($state{disable}{weapon}) {
      $weapon{name} = 'Free choice';
      $weapon{cost} = 0;
    }
    if ($state{disable}{grenades}) {
      $grenade1{name} = 'Free choice';
      $grenade2{name} = 'Free choice';
      $grenade1{cost} = 0;
      $grenade2{cost} = 0;
    }
    if ($state{disable}{utils}) {
      $util1{name} = 'Free choice';
      $util2{name} = 'Free choice';
      $util1{cost} = 0;
      $util2{cost} = 0;
    }
    if ($state{disable}{hardcore}) {
      my $hardcore_counter = 0;
      foreach(@hardcore) {
        $hardcore[$hardcore_counter] = 'None';
        $hardcore_counter++;
      }
    }

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # process all the data we got 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    _local_debug("[MAIN] : Processing cost and buy command data..");

    # calculate the total cost
    if($difficulty >= 0) {
      $data{total_cost} = $pistol{cost} + $weapon{cost};
    }
    if($difficulty >= 1) {
      $data{total_cost} = $data{total_cost} + $grenade1{cost} + $grenade2{cost};
    }
    if($difficulty >= 2) {
      $data{total_cost} = $data{total_cost} + $util1{cost} + $util2{cost};
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

    my $hardcore_string = join ';', @hardcore;

    _local_debug("[MAIN] : Finished process cost and buy command data.");

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # construct return data hash
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    $data{pistol_name}   = $pistol{name};
    $data{grenade_names} = $grenade1{name} . ';' . $grenade2{name};
    $data{util_names}    = $util1{name} . ';' . $util2{name};
    $data{weapon_name}   = $weapon{name};
    $data{strat_name}    = $strat{name};
    $data{strat_desc}    = $strat{desc};
    $data{hardcore}      = $hardcore_string;

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    if (%data) {
      return(%data);
    } else {
      die("no data generated");
    }

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
      _local_debug("[MAIN] : Found free choice, running difficulty $difficulty. Regenerating");
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
      _local_debug("[MAIN] : Found duplicate item (" . $item1->{buy} . "). Regenerating.");
      return 1;
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return 0;
  }

  ################################################################################
  # _local_debug subroutine
  ################################################################################
  sub _local_debug {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to the function
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $msg = shift;
  
    # only produce debug output if it is enabled for this module
    if ($DEBUG_STATE) {
      Util::Debug::Debug($msg);
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return;
  } 

  ### perl needs this
  1;
}
