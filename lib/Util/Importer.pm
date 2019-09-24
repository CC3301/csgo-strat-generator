package Util::Importer {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules 
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;

  use lib 'lib/';
  use Util::Encoder;

  ##############################################################################
  # Import subroutine
  ##############################################################################
  sub Import {
  
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get data passed to function 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $state = shift;
   
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $seed = Util::Encoder::decode_base32hex($state->{seed});

    # print debug message
    $debugger->write("[IMPRT]: Using seed: $seed");

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # process data from seend and save in hash  
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my %seed_data;

    # split the seed into its parts
    my @seed_parts = split ',', $seed;
    foreach(@seed_parts) {
      my @keys = split ':', $_;
      $seed_data{$keys[0]} = $keys[1];
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return(%seed_data);
  }

  # perl needs this
  1;
}
