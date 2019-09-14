package ReadInventory {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;
  use Cwd;

  use lib 'lib/';
  use Debug;

  # debug state for this module
  my $DEBUG_STATE = 0;
  
  ##############################################################################
  # Read subroutine
  ##############################################################################
  sub Read($) {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get item type 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $item_type = shift || die "No item type passed";
    _local_debug("[INV]  : Preparing to read inventory file for item type: $item_type");

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $line_count = 0;

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
    _local_debug("[INV]  : Reading inventory file: $file");
    open(ITEMS, $file) or die "Failed to read $item_type inventory: $!";

    # read the file line by line
    foreach my $line (<ITEMS>) {
      $item_list = $item_list . $line;
      $line_count++;
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    _local_debug("[INV]  : Done. Loaded $line_count data lines.");
    return($item_list);
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
      Debug::Debug($msg);
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return;
  }
  1;
}
