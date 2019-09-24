package Feature::Items {

  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;

  use lib 'lib/';
  use Util::Random;
  use Util::ReadInventory;

  #############################################################################
  # GetItem subroutine
  #############################################################################
  sub GetItem {
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get item_type 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $item_type = shift || die "No item type passed";
    $debugger->write("[ITEMS]: Generating dataset for $item_type");

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get items hash table 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my ($counter, %items) = _load_items($debugger, $item_type);

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get a random number with the max being the index counter
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $random_int = Util::Random::GetRandom($debugger, $counter);

    # return whatever is stored in the items hash at the random index
    my %return;
    $return{name} = $items{$random_int}{name};
    $return{buy}  = $items{$random_int}{buy};
    $return{cost} = $items{$random_int}{cost};
    
    return(%return);

  }
  
  #############################################################################
  # GetItemByBuy subroutine
  #############################################################################
  sub GetItemByBuy {
  
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to function 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $item_type = shift;
    my $target_buy = shift || die "No target buy passed";

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $local_counter = 0;
    my $found = 0;
    my %return;

    # debug message
    $debugger->write("[ITEMS]: Generating dataset for $item_type, want $target_buy");

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # load items hash 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my ($counter, %items) = _load_items($debugger, $item_type);
    
    # to through the hash and try to find the wanted buy
    until ($local_counter == $counter) {
      if ($target_buy eq $items{$local_counter}{buy}) {
        $found = 1;
        last;
      }
      $local_counter++;
    }
    
    # check if the item was found
    if ($found) {
      $debugger->write("[ITEMS]: Found requestet dataset for $item_type at $local_counter");
    } else {
      $debugger->write("[ITEMS]: Could not find requested dataset");
      die "Seed import failed. Requested item not found. Maybe update your inventory.";
    }
    
    # construct the return hash
    $return{name} = $items{$local_counter}{name};
    $return{buy} = $items{$local_counter}{buy};
    $return{cost} = $items{$local_counter}{cost};

    return(%return);

  }

  #############################################################################
  # _load_items subroutine
  #############################################################################
  sub _load_items {
  
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to function 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $item_type = shift;

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my %items;
    my $counter = 0;
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the list of items available and store them in a hash table
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $item_list = Util::ReadInventory::Read($debugger, $item_type); 
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
        $debugger->write("[ITEMS]: Can't continue on malformed data line");
        die();
      }

      # store data for return
      $items{$counter}{name} = $item_name;
      $items{$counter}{buy}  = $item_info[0];
      $items{$counter}{cost} = $item_info[1];
      
      # increment the index counter
      $counter++;
    }
    $debugger->write("[ITEMS]: Finished processing $item_type inventory file");
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return ($counter, %items);

  }
  # perl needs this
  1;
}
