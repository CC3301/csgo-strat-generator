package Util::Doc {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules 
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;
  use Cwd;

  ##############################################################################
  # List subroutine
  ##############################################################################
  sub List {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # what documentation files are available in the doc directory?
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $dir = getcwd() . "/data/doc/*";
    my @docfiles = glob($dir);

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # print out each element in the /data/doc directory 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    print "Documentation files available:\n\n";
    foreach(@docfiles) {
      (my $basename = $_) =~s/.*\///;
      print "\t- " . $basename . "\n";
    }
    print "\n";

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return();

  }

  ##############################################################################
  # Display subroutine
  ##############################################################################
  sub Display {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to the function
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $doc_type = shift;
    my $file = getcwd() . "/data/doc/$doc_type";

    $debugger->write("[DOC]  : Readind documentation file: $file");

    open(DOC, $file) or die "No such documentation file. Try using --doc-list";
      
      foreach my $line (<DOC>) {
        chomp $line;
        print "$line\n";
      }

    close DOC;
    
  }

  # perl needs this
  1; 
}
