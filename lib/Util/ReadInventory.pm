package Util::ReadInventory {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;
  use Cwd;
  
  ##############################################################################
  # Read subroutine
  ##############################################################################
  sub Read {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get item type 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $item_type = shift || die "No item type passed";
    $debugger->write("[INV]  : Preparing to read inventory file for item type: $item_type");

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $line_count = 0;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the weapons inventory file 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $file = getcwd() . "/data/inventory/$item_type.inv";

    # check if the file exists
    if (  ! -f $file) {
      die "No such item type: $item_type";
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # read the file 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $item_list = "";
    $debugger->write("[INV]  : Reading inventory file: $file");
    open(ITEMS, $file) or die "Failed to read $item_type inventory: $!";

    # read the file line by line
    foreach my $line (<ITEMS>) {
      $item_list = $item_list . $line;
      $line_count++;
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    $debugger->write("[INV]  : Done. Loaded $line_count data lines.");
    return($item_list);
  }
  
  # perl needs this
  1;
}
