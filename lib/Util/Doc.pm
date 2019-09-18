package Util::Doc {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules 
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;
  use Cwd;

  use lib 'lib/';
  use Util::Debug;

  my $DEBUG_STATE = 1;

  ##############################################################################
  # List subroutine
  ##############################################################################
  sub List {
    print "- general\n";
    print "- inventory\n";
  }

  ##############################################################################
  # Display subroutine
  ##############################################################################
  sub Display {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to the function
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $doc_type = shift;
    my $file = getcwd() . "/data/doc/$doc_type";

    _local_debug("[DOC]  : Readind documentation file: $file");

    open(DOC, $file) or die "No such documentation file. Try using --doc-list";
      
      foreach my $line (<DOC>) {
        chomp $line;
        print "$line\n";
      }

    close DOC;
    
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

  # perl needs this
  1; 
}