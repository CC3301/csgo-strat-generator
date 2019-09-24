#!/usr/bin/perl
use strict;
use warnings;

use lib 'lib/';
use Util::Debug;
use Util::Parser;
use Util::Exporter;
use Util::Doc;
use Main;

# debug for this main part of csgo-strat gen on or off
my $VERSION = 'v1.0';

################################################################################
# Main subroutine
################################################################################
sub Main() {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # handle debugging 
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my $debug_state = 0;
  if (defined($ARGV[0]) && $ARGV[0] eq '--debug') {
    shift(@ARGV);
    $debug_state = 1;
    eval {
      use Carp::Always;
    };
    if (@_) {
      print "Failed to load Carp::Always. No stacktraces will be available.\n";
    }
  }
  my $debugger = Util::Debug->new(
    enable => $debug_state,
    logfile => 'log/latest.log',
  );

  # send debug message about the program start
  $debugger->write("[WRAP] : Kicking off csgo-strat-generator $VERSION");

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # parse command line options
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my %state = Util::Parser::Parse($debugger, @ARGV);

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # other vars 
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my $difficulty = $state{difficulty};
  
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # check if help or rules are required 
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  if ($state{help}) {
    Util::Doc::Display($debugger, 'help');
    $debugger->write("[MAIN] : Early exit. Help was displayed.");
    exit();
  }
  if ($state{rules}) {
    Util::Doc::Display($debugger, 'rules');
    $debugger->write("[MAIN] : Early exit. Rules were displayed.");
    exit();
  }
  if ($state{display_doc}) {
    Util::Doc::Display($debugger, $state{display_doc_type});
    $debugger->write("[MAIN] : Early exit. Documentation was requested.");
    exit();
  }
  if ($state{doc_list}) {
    Util::Doc::List($debugger);
    $debugger->write("[MAIN] : Early exit. Documentation was listed.");
    exit();
  }

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # get os type
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my $OS_TYPE = $^O;
  if ($OS_TYPE eq 'MSWin32') {
    $state{os_type} = 'windows';
  } elsif ($OS_TYPE eq 'linux') {
    $state{os_type} = 'linux';
  } elsif ($OS_TYPE eq 'darwin') {
    $state{os_type} = 'mac';
  } 

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # get dataset 
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  my %data;
  ($difficulty, %data) = Main::Run($debugger, $difficulty, \%state);
  $state{difficulty} = $difficulty;

  # check if there was anything returned
  if (! %data) {
    $debugger->write("[WRAP] : Didn't get dataset. Using import: " . $state{import_seed} ? "Yes" : "No" );
    die "Dataset generation failure";
  }

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # print output 
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  $debugger->write("[WRAP] : Priting output");
  print "CSGO strat-generator $VERSION output:\n\n";
  print "===================================================================\n";
  
  if ($difficulty >= 0 && (! $state{disable}{pistol} || $state{display_disabled})) {
    print "Pistol   : " . $data{pistol_name}   . "\n";
  }
  if ($difficulty >= 0 && (! $state{disable}{weapon} || $state{display_disabled})) {
    print "Weapon   : " . $data{weapon_name}   . "\n";
  }
  if ($difficulty >= 1 && (! $state{disable}{grenades} || $state{display_disabled})) {
    print "\n";
    print "Grenades: \n";
    foreach(split ';', $data{grenade_names}) {
      print "\t- $_\n";
    }
  }
  if ($difficulty >= 2 && (! $state{disable}{utils} || $state{display_disabled})) {
    print "\n";
    print "Utilities: \n";
    foreach(split ';', $data{util_names}) {
      print "\t- $_\n";
    }
  }
  if ($difficulty >= 6 && (! $state{disable}{hardcore} || $state{display_disabled})) {
    print "\n";
    print "Hardcore settings: \n";
    foreach(split ';', $data{hardcore}) {
      print "\t- $_\n";
    }
    print "\nNOTE: Hardcore settings overwrite strats and generated weapon sets.\n";
  }
  if ($difficulty >= 3 && (! $state{disable}{strats} || $state{display_disabled})) {
    print "\n";
    print "Strat: " . $data{strat_name} . "\n";
    print "Description:\n";
    foreach(split ';', $data{strat_desc}) {
      print "\t$_\n";
    }
  }

  # print the rest of the stats
  print "===================================================================\n";
  print "\nDifficulty   : $difficulty\n";

  if ($data{total_cost_ct} == $data{total_cost_t}) {
    print "Total Cost   : $data{total_cost_ct}\$\n\n";
  } else {
    print "Total Cost T : $data{total_cost_t}\$\n";
    print "Total Cost CT: $data{total_cost_ct}\$\n\n";
  }
  print "Command:\n\tbind $state{default_key} \"$data{command_string}\"\n";

  # should the output be saved?
  if ($state{write_output}) {
    Util::Exporter::Export($debugger, \%data, \%state);
  }
  
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # return
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  $debugger->write("[WRAP] : csgo strat gen complete.");
  return(0);
  
}


################################################################################
# Main subroutine call 
################################################################################
exit(Main());
