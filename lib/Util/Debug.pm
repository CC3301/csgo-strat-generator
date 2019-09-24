package Util::Debug {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;
  use Cwd;

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
