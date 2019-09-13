package Random {
 
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;

  #############################################################################
  # GetRandom subroutine
  #############################################################################
  sub GetRandom {
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to the function
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $max = shift;
    my $min = shift || 0;
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get random int 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $random_int = int(rand($max) + $min);

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return $random_int; 

  }
  # perl needs this
  1;
}
