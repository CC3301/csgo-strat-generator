package Util::Parser {
  
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;

  #############################################################################
  # Parse subroutine
  #############################################################################
  sub Parse {

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to this function
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my @args = @_;

    $debugger->write("[PARSE]: Parsing command line options..");
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $counter = 0;
    my @nexts;
    my $skip = 0;

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get default values 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my %state = _set_default($debugger);
    %state    = _get_config($debugger, \%state);

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # parse the args 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    foreach my $switch (@args) {

      $skip = 0;
      $debugger->write("[PARSE]: Option : $switch as $counter option");

      if ($switch eq '-d' || $switch eq '--difficulty') {
        if ($args[$counter+1] !~ /^-?\d+$/) {
          die("--difficulty | -d :: option requires integer number argument");
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
          die("--default-key | -k :: option requires single character argument");
        }
        $state{default_key} = $args[$counter+1];
        push @nexts, $args[$counter+1];
      } elsif ($switch eq '--display-disabled') {
        $state{display_disabled} = 1;
      } elsif ($switch eq '--write') {
        $state{write_output} = 1;
        $state{write_file} = 1;
      } elsif ($switch eq '--write-csgo') {
        $state{write_output} = 1;
        $state{write_csgo} = 1;
      } elsif ($switch eq '--doc') {
        if (length($args[$counter+1]) == 0) {
          die("--doc :: option requires string type argument");
        }
        $state{display_doc} = 1;
        $state{display_doc_type} = $args[$counter+1];
        push @nexts, $args[$counter+1];
      } elsif ($switch eq '--doc-list') {
        $state{doc_list} = 1;
      } elsif ($switch eq '--import') {
        if (length($args[$counter+1]) == 0) {
          die("--import :: option requires string type argument");
        }
        $state{import_seed} = 1;
        $state{seed} = $args[$counter+1];
        push @nexts, $args[$counter+1];
      } elsif ($switch eq '--export') {
        $state{write_output} = 1;
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
        die("general error in command line options. Unknown parameter.");

      }
      $counter++;
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # print all the settings when debut state is set to 2 or higher 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    $debugger->write("[PARSE]: Setting: help              => $state{help}");
    $debugger->write("[PARSE]: Setting: rules             => $state{rules}");
    $debugger->write("[PARSE]: Setting: difficulty        => $state{difficulty}");
    $debugger->write("[PARSE]: Setting: default_key       => $state{default_key}");
    $debugger->write("[PARSE]: Setting: disable->pistol   => $state{disable}{pistol}");
    $debugger->write("[PARSE]: Setting: disable->weapon   => $state{disable}{weapon}");
    $debugger->write("[PARSE]: Setting: disable->grenades => $state{disable}{grenades}");
    $debugger->write("[PARSE]: Setting: disable->utils    => $state{disable}{utils}");
    $debugger->write("[PARSE]: Setting: disable->hardcore => $state{disable}{hardcore}");
    $debugger->write("[PARSE]: Setting: disable->strats   => $state{disable}{strats}");
    $debugger->write("[PARSE]: Setting: display_disabled  => $state{display_disabled}");
    $debugger->write("[PARSE]: Setting: write_output      => $state{write_output}");
    $debugger->write("[PARSE]: Setting: write_csgo        => $state{write_csgo}");
    $debugger->write("[PARSE]: Setting: write_file        => $state{write_file}");
    $debugger->write("[PARSE]: Setting: display_doc       => $state{display_doc}");
    $debugger->write("[PARSE]: Setting: display_doc_type  => $state{display_doc_type}");
    $debugger->write("[PARSE]: Setting: doc_list          => $state{doc_list}");
    $debugger->write("[PARSE]: Setting: import_seed       => $state{import_seed}");
    $debugger->write("[PARSE]: Setting: seed              => $state{seed}");
    $debugger->write("[PARSE]: Setting: export_seed       => $state{export_seed}");

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return settings 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    $debugger->write("[PARSE]: Finished parsing command line.");
    return(%state);

  }

  ##############################################################################
  # _set_default subroutine 
  ##############################################################################
  sub _set_default {
  
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get data passed to function 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;

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
    $state{write_file}        = 0;
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
    $debugger->write("[PARSE]: Loaded default values for the current version.");
    return(%state);
  }

  ##############################################################################
  # _get_config subroutine
  ##############################################################################
  sub _get_config {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to function 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $state = shift || die "Config parse error";

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $file = 'data/config';
    my %special_keys = (
      'write_file' => 'write_output',
      'write_csgo' => 'write_output',
      'export_seed' => 'write_output',
    );

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # Open config file for reading 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    open(CFG, $file) or warn "config file not found";
      foreach(<CFG>) {

        # skip newlines and empty lines
        next if $_ eq '' || $_ eq "\n";
        chomp $_;

        my ($value, @keys) = _parse_config_line($debugger, $_);
        $debugger->write("[PARSE]: Config : " . join('.', @keys) . " :: $value");
        
        # check if key triggers other keys
        foreach(keys %special_keys) {
          if ($_ eq $keys[0]) {
            $debugger->write("[PARSE]: Config: Found recusring key: $keys[0] -> $special_keys{$_}");
            $state->{$special_keys{$_}} = $value;
          }
        }

        # write keys
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
    my $debugger = shift;
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
      "write_file",
      "export_seed",
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
    die("Illegal config key") unless $key_valid;

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

  # perl needs this
  1;
}
