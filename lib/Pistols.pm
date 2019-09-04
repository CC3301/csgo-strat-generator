package Pistols {

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
  sub GetPistol() {
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my %pistols;
    my $counter = 0;
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the list of weapons available and store them in a hash table
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $pistol_list = _read_pistol_file(); 
    my @pistols = split "\n", $pistol_list;
    
    # go through all weapons and get their stats
    foreach my $pistol (@pistols) {

      # skip empty lins 
      if ( $pistol eq '' || $pistol eq "\n" ) {
        next;
      }

      # parse the current line
      my $pistol_name = substr($pistol, 0, index($pistol, ':'));
      my @pistol_info = split ',', substr($pistol, index($pistol, $pistol_name) + length($pistol_name) + 1);
      my $pistol_buy  = $pistol_info[0];
      my $pistol_cost = $pistol_info[1];

      # check if the line is valid
      if ( ! @pistol_info == 2 ) {
        die "Malformed weapon inventory file";
      }

      # store data
      $pistols{$counter}{name} = $pistol_name;
      $pistols{$counter}{buy}  = $pistol_info[0];
      $pistols{$counter}{cost} = $pistol_info[1];
      
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
  sub _read_pistol_file() {

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the weapons inventory file 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $file = getcwd() . "/data/pistols.inv";

    # check if the file exists
    if (  ! -f $file) {
      die "No pistols inventory: $!";
    }

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # read the file 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $pistol_list = "";
    open(PISTOLS, $file) or die "Failed to read pistols inventory: $!";

    # read the file line by line
    foreach my $line (<PISTOLS>) {
      $pistol_list = $pistol_list . $line;
    }

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return($pistol_list);
  }
  1;
}
