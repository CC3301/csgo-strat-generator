package Util::Parser {
  
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;
  
  use lib 'lib/';
  use Util::Debug;

  my $DEBUG_STATE = 1;

  #############################################################################
  # Parse subroutine
  #############################################################################
  sub Parse {

    _local_debug("[PARSE]: Parsing command line options..");

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to this function
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my @args = @_;

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $counter = 0;
    my @nexts;
    my $skip = 0;

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get default values 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my %state = _set_default();

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # parse the args 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    foreach my $switch (@args) {

      $skip = 0;
      _local_debug("[PARSE]: Handling option: $switch as $counter option");

      if ($switch eq '-d' || $switch eq '--difficulty') {
        if ($args[$counter+1] !~ /^-?\d+$/) {
          _local_error("--difficulty | -d :: option requires integer number argument");
        }
        $state{difficulty} = $args[$counter+1];
        push @nexts, $args[$counter+1];
      } elsif ($switch eq '-h' || $switch eq '--help') {
        $state{help} = 1;
      } elsif ($switch eq '-r' || $switch eq '--rules') {
        $state{rules} = 1;
      } elsif ($switch eq '--disable-pistol') {
        $state{disable}{pistol} = 1;
      } elsif ($switch eq '--disable-weapon') {
        $state{disable}{weapon} = 1;
      } elsif ($switch eq '--disable-grenades') {
        $state{disable}{grenades} = 1;
      } elsif ($switch eq '--disable-utils') {
        $state{disable}{utils} = 1;
      } elsif ($switch eq '--disable-hardcore') {
        $state{disable}{hardcore} = 1;
      } elsif ($switch eq '--disable-strats') {
        $state{disable}{strats} = 1;
      } elsif ($switch eq '--force-hardcore') {
        $state{disable}{hardcore} = 0;
      } elsif ($switch eq '-k' || $switch eq '--default-key') {
        if (length($args[$counter+1]) != 1 ) {
          _local_error("--default-key | -k :: option requires single character argument");
        }
        $state{default_key} = $args[$counter+1];
        print "TEST: $args[$counter+1]\n";
        push @nexts, $args[$counter+1];
      } elsif ($switch eq '--display-disabled') {
        $state{display_disabled} = 1;
      } elsif ($switch eq '--write') {
        $state{write_output} = 1;
      } else {

        foreach(@nexts) {
          if ($_ eq $switch) {
            $skip = 1;
            next;
          }
        }
        
        
        if ($skip) {
          $counter++;
          next;
        }
        _local_error("general error in command line options. Unknown parameter.");

      }
      $counter++;
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # print all the settings when debut state is set to 2 or higher 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    _local_debug("[PARSE]: Setting: help              => $state{help}");
    _local_debug("[PARSE]: Setting: rules             => $state{rules}");
    _local_debug("[PARSE]: Setting: difficulty        => $state{difficulty}");
    _local_debug("[PARSE]: Setting: default_key       => $state{default_key}");
    _local_debug("[PARSE]: Setting: disable->pistol   => $state{disable}{pistol}");
    _local_debug("[PARSE]: Setting: disable->weapon   => $state{disable}{weapon}");
    _local_debug("[PARSE]: Setting: disable->grenades => $state{disable}{grenades}");
    _local_debug("[PARSE]: Setting: disable->utils    => $state{disable}{utils}");
    _local_debug("[PARSE]: Setting: disable->hardcore => $state{disable}{hardcore}");
    _local_debug("[PARSE]: Setting: disable->strats   => $state{disable}{strats}");
    _local_debug("[PARSE]: Setting: display_disabled  => $state{display_disabled}");
    _local_debug("[PARSE]: Setting: write_output      => $state{write_output}");

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return settings 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    _local_debug("[PARSE]: Finished parsing command line.");
    return(%state);

  }

  ##############################################################################
  # _set_default subroutine 
  ##############################################################################
  sub _set_default() {
  
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # save the default values 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my %state;

    $state{help}             = 0;
    $state{rules}            = 0;
    $state{difficulty}       = 0;
    $state{default_key}      = 'c';
    $state{display_disabled} = 0; 
    $state{write_output}     = 0;
    
    $state{disable}{pistol}   = 0;
    $state{disable}{weapon}   = 0;
    $state{disable}{grenades} = 0;
    $state{disable}{utils}    = 0;
    $state{disable}{hardcore} = 1;
    $state{disable}{strats}   = 0;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return default values
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    _local_debug("[PARSE]: Loaded default values for the current version.");
    return(%state);
  }

  ##############################################################################
  # _local_error subroutine
  ##############################################################################
  sub _local_error {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to the function
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    die(shift);

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
