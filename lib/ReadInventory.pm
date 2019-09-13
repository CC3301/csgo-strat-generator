package ReadInventory {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;
  use Cwd;

  use lib 'lib/';
  use Debug;
  
  ##############################################################################
  # Read subroutine
  ##############################################################################
  sub Read($) {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get item type 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $item_type = shift || die "No item type passed";
    Debug::Debug("Preparing to read inventory file for item type: $item_type");


    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the weapons inventory file 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $file = getcwd() . "/data/$item_type.inv";

    # check if the file exists
    if (  ! -f $file) {
      die "No such item type: $item_type";
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # read the file 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $item_list = "";
    Debug::Debug("Reading inventory file: $file");
    open(ITEMS, $file) or die "Failed to read $item_type inventory: $!";

    # read the file line by line
    foreach my $line (<ITEMS>) {
      $item_list = $item_list . $line;
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Debug::Debug("Done.");
    return($item_list);
  }
  1;
}
