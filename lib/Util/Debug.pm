package Util::Debug {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;
  use Cwd;

  ##############################################################################
  # Debug subroutine
  ##############################################################################
  sub Debug {

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
  # constructor 
  ##############################################################################
  sub new {
    
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # construct new debugger object 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my ($class,%args) = @_;

    my $self = bless \%args,$class;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # check if the debugger is enabled and then print a message 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    if ($args{enable}) {
      print "DEBUG: Enabled. File: $args{logfile}\n";
      $self->write("[DEBUG]: Enabled");
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return object 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return $self; 

  }

  ##############################################################################
  # write debug message 
  ##############################################################################
  sub write {
    
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the debug message, write it to the file 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my ($self,$message) = @_;
    
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # handle processing and writing the message
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    # return if the debug mode is not enabled
    unless($self->{enable}) {
      return();
    } 

    # get timestamp
    my $timestamp = localtime(time());

    # build the debug message
    $message = "[$timestamp]: DEBUG: $message\n";

    # write the message
    open (my $fh, '>>', $self->{logfile}) or die "Failed to open debug log: $!";
      print $fh $message;
    close $fh;

  }

  # perl needs this
  1;
}
