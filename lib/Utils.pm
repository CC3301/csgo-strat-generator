package Utils {

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
  sub GetUtil() {
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my %utils;
    my $counter = 0;

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the list of weapons available 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $util_list = _read_util_file(); 
    my @utils = split "\n", $util_list;
    
    # go through all weapons and get their stats
    foreach my $util (@utils) {

      # skip empty lins 
      if ( $util eq '' || $util eq "\n" ) {
        next;
      }

      # parse the current line
      my $util_name = substr($util, 0, index($util, ':'));
      my @util_info = split ',', substr($util, index($util, $util_name) + length($util_name) + 1);
      my $util_buy  = $util_info[0];
      my $util_cost = $util_info[1];

      # check if the line is valid
      if ( ! @util_info == 2 ) {
        die "Malformed weapon inventory file";
      }

      # store data
      $utils{$counter}{name} = $util_name;
      $utils{$counter}{buy}  = $util_info[0];
      $utils{$counter}{cost} = $util_info[1];

      # increment the index counter
      $counter++;
    }

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get a random number with the max being the index counter
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $random_int = Random::GetRandom($counter);

    my %return;
    $return{name} = $utils{$random_int}{name};
    $return{buy}  = $utils{$random_int}{buy};
    $return{cost} = $utils{$random_int}{cost};
    
    return(%return);
  }
  #############################################################################
  # _read_weapon_file subroutine 
  #############################################################################
  sub _read_util_file() {

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the weapons inventory file 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $file = getcwd() . "/data/utils.inv";

    # check if the file exists
    if (  ! -f $file) {
      die "No utils inventory: $!";
    }

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # read the file 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $util_list = "";
    open(UTILS, $file) or die "Failed to read grenades inventory: $!";

    # read the file line by line
    foreach my $line (<UTILS>) {
      $util_list = $util_list . $line;
    }

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return($util_list);
  }
  1;
}
