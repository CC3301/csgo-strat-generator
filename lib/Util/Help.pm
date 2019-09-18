package Util::Help {

  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;

  use lib 'lib/';
  use Util::ReadInventory;

  #############################################################################
  # ShowHelp subroutine
  #############################################################################
  sub ShowMsg($) {
   
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to the fuction
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $type = shift || 'help';

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # check that we only read the allowed inventory files 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    unless($type eq 'help' || $type eq 'rules') {
      die "Illegal file access.";
    }
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get data from inventory file
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $data = Util::ReadInventory::Read($type);

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # print data 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    foreach(split "\n", $data) {
      print "$_\n";
    }

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return();
  }
  
  # perl needs this
  1;
}