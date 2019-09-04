package Weapons {

  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;
  use Cwd;

  use lib 'lib/';
  use Random;

  #############################################################################
  # GetWeapon subroutine
  #############################################################################
  sub GetWeapon() {
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my %weapons;
    my $counter = 0;
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the list of weapons available and store them in a hash table
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $weapon_list = _read_weapon_file(); 
    my @weapons = split "\n", $weapon_list;
    
    # go through all weapons and get their stats
    foreach my $weapon (@weapons) {

      # skip empty lins 
      if ( $weapon eq '' || $weapon eq "\n" ) {
        next;
      }

      # parse the current line
      my $weapon_name = substr($weapon, 0, index($weapon, ':'));
      my @weapon_info = split ',', substr($weapon, index($weapon, $weapon_name) + length($weapon_name) + 1);
      my $weapon_buy  = $weapon_info[0];
      my $weapon_cost = $weapon_info[1];

      # check if the line is valid
      if ( ! @weapon_info == 2 ) {
        die "Malformed weapon inventory file";
      }

      # store data
      $weapons{$counter}{name} = $weapon_name;
      $weapons{$counter}{buy}  = $weapon_info[0];
      $weapons{$counter}{cost} = $weapon_info[1];
      
      # increment the index counter
      $counter++;
    }

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get a random number with the max being the index counter
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $random_int = Random::GetRandom($counter);
    
    my %return;
    $return{name} = $pistols{$random_int}{name};
    $return{buy}  = $pistols{$random_int}{buy};
    $return{cost} = $pistols{$random_int}{cost};
    
    return(%return);

  }
  #############################################################################
  # _read_weapon_file subroutine 
  #############################################################################
  sub _read_weapon_file() {

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the weapons inventory file 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $file = getcwd() . "/data/weapons.inv";

    # check if the file exists
    if (  ! -f $file) {
      die "No weapons inventory: $!";
    }

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # read the file 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $weapon_list = "";
    open(WEAPONS, $file) or die "Failed to read weapons inventory: $!";

    # read the file line by line
    foreach my $line (<WEAPONS>) {
      $weapon_list = $weapon_list . $line;
    }

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return($weapon_list);
  }
  1;
}
