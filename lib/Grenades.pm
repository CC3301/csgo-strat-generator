
package Grenades {

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
  sub GetGrenade() {
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my %grenades;
    my $counter = 0;

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the list of weapons available 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $grenade_list = _read_grenade_file(); 
    my @grenades = split "\n", $grenade_list;
    
    # go through all weapons and get their stats
    foreach my $grenade (@grenades) {

      # skip empty lins 
      if ( $grenade eq '' || $grenade eq "\n" ) {
        next;
      }

      # parse the current line
      my $grenade_name = substr($grenade, 0, index($grenade, ':'));
      my @grenade_info = split ',', substr($grenade, index($grenade, $grenade_name) + length($grenade_name) + 1);
      my $grenade_buy  = $grenade_info[0];
      my $grenade_cost = $grenade_info[1];

      # check if the line is valid
      if ( ! @grenade_info == 2 ) {
        die "Malformed weapon inventory file";
      }

      # store data
      $grenades{$counter}{name} = $grenade_name;
      $grenades{$counter}{buy}  = $grenade_info[0];
      $grenades{$counter}{cost} = $grenade_info[1];

      # increment the index counter
      $counter++;
    }

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get a random number with the max being the index counter and return the
    # corresponding items
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $random_int = Random::GetRandom($counter);

    my %return;
    $return{name} = $grenades{$random_int}{name};
    $return{buy}  = $grenades{$random_int}{buy};
    $return{cost} = $grenades{$random_int}{cost};
    
    return(%return);
    
  }
  #############################################################################
  # _read_weapon_file subroutine 
  #############################################################################
  sub _read_grenade_file() {

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the weapons inventory file 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $file = getcwd() . "/data/grenades.inv";

    # check if the file exists
    if (  ! -f $file) {
      die "No grenades inventory: $!";
    }

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # read the file 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $grenade_list = "";
    open(GRENADES, $file) or die "Failed to read grenades inventory: $!";

    # read the file line by line
    foreach my $line (<GRENADES>) {
      $grenade_list = $grenade_list . $line;
    }

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return($grenade_list);
  }
  1;
}
