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
    %state    = _get_config(\%state);

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # parse the args 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    foreach my $switch (@args) {

      $skip = 0;
      _local_debug("[PARSE]: Option : $switch as $counter option");

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
        push @nexts, $args[$counter+1];
      } elsif ($switch eq '--display-disabled') {
        $state{display_disabled} = 1;
      } elsif ($switch eq '--write') {
        $state{write_output} = 1;
      } elsif ($switch eq '--write-csgo') {
        $state{write_csgo} = 1;
      } elsif ($switch eq '--doc') {
        if (length($args[$counter+1]) == 0) {
          _local_error("--doc :: option requires string type argument");
        }
        $state{display_doc} = 1;
        $state{display_doc_type} = $args[$counter+1];
        push @nexts, $args[$counter+1];
      } elsif ($switch eq '--doc-list') {
        $state{doc_list} = 1;
      } elsif ($switch eq '--import') {
        if (length($args[$counter+1]) == 0) {
          _local_error("--import :: option requires string type argument");
        }
        $state{import_seed} = 1;
        $state{seed} = $args[$counter+1];
        push @nexts, $args[$counter+1];
      } elsif ($switch eq '--export') {
        $state{export_seed} = 1;
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
    _local_debug("[PARSE]: Setting: write_csgo        => $state{write_csgo}");
    _local_debug("[PARSE]: Setting: display_doc       => $state{display_doc}");
    _local_debug("[PARSE]: Setting: display_doc_type  => $state{display_doc_type}");
    _local_debug("[PARSE]: Setting: doc_list          => $state{doc_list}");
    _local_debug("[PARSE]: Setting: import_seed       => $state{import_seed}");
    _local_debug("[PARSE]: Setting: seed              => $state{seed}");
    _local_debug("[PARSE]: Setting: export_seed       => $state{export_seed}");

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

    $state{help}              = 0;
    $state{rules}             = 0;
    $state{difficulty}        = 0;
    $state{default_key}       = '<key>';
    $state{display_disabled}  = 0; 
    $state{write_output}      = 0;
    $state{write_csgo}        = 0;
    $state{display_doc}       = 0;
    $state{display_doc_type}  = '';
    $state{doc_list}          = 0;
    $state{import_seed}       = 0;
    $state{seed}              = '';
    $state{export_seed}       = 0;

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
  # _get_config subroutine
  ##############################################################################
  sub _get_config {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to function 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $state = shift || die "Config parse error";

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $file = 'data/config';

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # Open config file for reading 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    open(CFG, $file) or warn "config file not found";
      foreach(<CFG>) {

        # skip newlines and empty lines
        next if $_ eq '' || $_ eq "\n";
        chomp $_;

        my ($value, @keys) = _parse_config_line($_);
        _local_debug("[PARSE]: Config : " . join('.', @keys) . " :: $value");

        if (@keys > 1) {
          $state->{$keys[0]}->{$keys[1]}  = $value;
        } else {
          $state->{$keys[0]} = $value;
        }
      }

    close CFG;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return values loaded from config 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return(%$state)
  }

  ##############################################################################
  # _parse_config_line subroutine 
  ##############################################################################
  sub _parse_config_line {
  
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to function 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $line = shift || die "Config parse error";

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my @allowed_keys = (
      "difficulty",
      "default_key",
      "disable.pistol",
      "disable.weapon",
      "disable.grenades",
      "disable.utils",
      "disable.hardcore",
      "disable.strats",
      "write_output",
      "write_csgo",
    );
    my $key_valid = 0;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # parse the config line 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    # get the current key
    my $key_str = substr($line, 0, index($line, ':'));

    # check if the key is allowed
    foreach(@allowed_keys) {
      if ($_ eq $key_str) {
        $key_valid = 1;
      }
    }
      
    # die when the key is not allowed
    _local_error("Illegal config key") unless $key_valid;

    # parse the rest of the current line
    my $value   = substr($line, index($line, $key_str) + length($key_str) + 1);
    my @keys    = split '.', $key_str;

    unless(@keys) {
      $keys[0] = $key_str;
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return values loaded from config 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return($value, @keys);
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
