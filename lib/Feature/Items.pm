package Feature::Items {

  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;

  use lib 'lib/';
  use Util::Random;
  use Util::ReadInventory;
  use Util::Debug;

  # debug state for this module
  my $DEBUG_STATE = 0;

  #############################################################################
  # GetWeapon subroutine
  #############################################################################
  sub GetItem($) {
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get item_type 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $item_type = shift || die "No item type passed";
    _local_debug("[ITEMS]: Generating dataset for $item_type");

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my %items;
    my $counter = 0;
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the list of weapons available and store them in a hash table
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $item_list = Util::ReadInventory::Read($item_type); 
    my @items = split "\n", $item_list;
    
    # go through all weapons and get their stats
    foreach my $item (@items) {

      # skip empty lins 
      if ( $item eq '' || $item eq "\n" ) {
        next;
      }

      # parse the current line
      my $item_name = substr($item, 0, index($item, ':'));
      my @item_info = split ',', substr($item, index($item, $item_name) + length($item_name) + 1);
      my $item_buy  = $item_info[0];
      my $item_cost = $item_info[1];

      # check if the line is valid
      unless (@item_info == 2) {
        my $h_counter = $counter+1;
        print "Malformed inventory file\n";
        print "\tI suspect the error to be near to:\n";
        print "\t\t$items[$counter]\n";
        print "\tin /data/$item_type.inv at line $h_counter\n";
        _local_debug("[ITEMS]: Can't continue on malformed data line");
        die();
      }

      # store data for return
      $items{$counter}{name} = $item_name;
      $items{$counter}{buy}  = $item_info[0];
      $items{$counter}{cost} = $item_info[1];
      
      # increment the index counter
      $counter++;
    }

    _local_debug("[ITEMS]: Finished processing $item_type inventory file");

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get a random number with the max being the index counter
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $random_int = Util::Random::GetRandom($counter);

    # return whatever is stored in the items hash at the random index
    my %return;
    $return{name} = $items{$random_int}{name};
    $return{buy}  = $items{$random_int}{buy};
    $return{cost} = $items{$random_int}{cost};
    
    return(%return);

  }
  ##############################################################################
  # _local_debug subroutine
  ##############################################################################
  sub _local_debug {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to the function
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $msg = shift;

    # only produce debug output if it is enabled for this module
    if ($DEBUG_STATE) {
      Util::Debug::Debug($msg);
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return;
  }
  1;
}
