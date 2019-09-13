package Debug {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;
  use Cwd;

  my $DEBUG_ACTIVE = 1;

  ##############################################################################
  # Debug subroutine
  ##############################################################################
  sub Debug {

    # only produce debug output when its wanted
    unless($DEBUG_ACTIVE) {
      return;
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # what debug message should be written
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debug_message = shift;
    my $raw = shift || 0;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # handle and write the debug message
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # open the debug file for wirting
    my $debug_file = getcwd() . "/log/" . "latest";

    # check if the debug file already exists
    if ( -e $debug_file ) {
      $debug_file = $debug_file . int(rand(1000)) . ".log";
    } else {
      $debug_file = $debug_file . ".log";
    }
    my $timestamp = localtime(time());

    # construct the message
    unless($raw) {
      $debug_message = "[$timestamp]: DEBUG: $debug_message\n";
    }

    # open the debug file, write to it and close
    open my $fh, '>>', $debug_file or die "Failed to open debug log: $!";
      print $fh $debug_message;
    close $fh;

    # return
    return();

  }

  ##############################################################################
  # _get_timestamp subroutine
  ##############################################################################
  sub _get_timestamp($) {

    ;;

  }
  1;
}