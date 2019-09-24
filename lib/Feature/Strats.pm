package Feature::Strats {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;

  use lib 'lib/';
  use Util::ReadInventory;
  use Util::Random;

  # debug state for this module
  my $DEBUG_STATE = 0;

  ##############################################################################
  # GetStrat subroutine
  ##############################################################################
  sub GetStrat {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # what strat score are we aiming for 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $target_score = shift;
    my $target_name = shift;
    my $state = shift;

    $debugger->write("[STRAT]: Targetting strat score: $target_score");

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my %return;
    my $local_counter = 0;
    my $found = 0;
    my $do_until = 1;
      
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # load the strats inventory 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my ($counter, %strats) = _load_strats($debugger);


    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # tell the score calculation system what kind of score we are aiming for
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $strat_index = _eval_strat_score($debugger, $counter, $target_score, %strats);

    # check if we even found a strat and if yes, then return the details about
    # this strat
    if ($state->{import_seed}) {

      if ($target_name eq 'Anonymus') {
        $strat_index = 'error';
        $found = 1;
        $do_until = 0;
      }
      
      if ($do_until) {
        until($local_counter == $counter) {
          if ($strats{$local_counter}{name} eq $target_name) {
            $found = 1;
            $strat_index = $local_counter;
            last;
          }
          $local_counter++;
        }
      }
    }

    if ($strat_index eq 'error') {
      $return{name}  = "Anonymus";
      $return{desc}  = "I am sorry, but i didnt find any strat for you";
      $return{score} = 0;
      $debugger->write("[STRAT]: Could not find matching strategy with score"); 
    } else {
      $return{name}  = $strats{$strat_index}{name};
      $return{desc}  = $strats{$strat_index}{desc};
      $return{score} = $strats{$strat_index}{score};
      $debugger->write("[STRAT]: Found matching strategy with score: " . $return{score});
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return(%return);

  }

  ##############################################################################
  # _load_strats subroutine 
  ##############################################################################
  sub _load_strats {
  
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to function 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my %strats;
    my $counter = 0; 

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the list of strats available and store them in a hash 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $strat_list = Util::ReadInventory::Read($debugger, 'strats');
    my @strats = split "\n", $strat_list;

    # go through all strats and get their stats
    foreach my $strat (@strats) {

      # skip empty lines
      if ( $strat eq '' || $strat eq "\n") {
        next;
      }

      # parse the current line
      my $strat_name  = substr($strat, 0, index($strat, ':'));
      my @strat_info  = split ',', substr($strat, index($strat, $strat_name) + length($strat_name) + 1);
      my $strat_desc  = $strat_info[0];
      my $strat_score = $strat_info[1];

      # check if the line is valid
      unless (@strat_info == 2) {
        my $h_counter = $counter+1;
        print "Malformed inventory file\n";
        print "\tI suspect the error to be near to:\n";
        print "\t\t$strats[$counter]\n";
        print "\tin /data/strats.inv at line $h_counter\n";
        $debugger->write("[STRAT]: Can't continue on malformed data line");
        die();
      }

      # store data in strats hash
      $strats{$counter}{name}  = $strat_name;
      $strats{$counter}{desc}  = $strat_desc;
      $strats{$counter}{score} = $strat_info[1];
    
      # increment the index counter
      $counter++;
    }

    $debugger->write("[STRAT]: Finished processing strategy inventory");

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return strats
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return($counter, %strats);
  }

  ##############################################################################
  # _eval_strat_score subroutine 
  ##############################################################################
  sub _eval_strat_score {
    
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get passed values
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $target_counter = shift;
    my $target_score   = shift;
    my %strats         = @_;
   
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $counter = 0;
    my $result_index = 'error';
    my $current_iteration = 0;
    my @scores;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # run through the passed hash and find the score that matches closest
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    until ($counter == $target_counter) {
    
      # get the current strat's score
      my $current_score = $strats{$counter}{score};
      push @scores, $current_score;   
    
      # increment the counter
      $counter++;
    }
    $debugger->write("[STRAT]: Total strats loaded: $counter");

    # randomize the contents of @scores
    $debugger->write("[STRAT]: Randomizing scores array");
    @scores = _shuffle($debugger, \@scores);

    # get a random score
    my $random_score = _get_random_score($debugger, $target_score, @scores);
    while($random_score > @scores) {
      $debugger->write("[STRAT]: Random score too high. Regenerating.");
      $random_score = _get_random_score($debugger, $target_score, @scores);
    }

    # check if there was an error and some data was lost, or magically created
    unless (@scores == $target_counter || @scores == $counter) {
      die "Number of inventory strats does not match the number of strats I counted";
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # loop through the scored and try to find a matching score
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # since the counter starts at 0, the 0 element in @scores equals to the 0 
    # element in %strats.
    foreach my $score (@scores) {

      # check if the current iteration is as big as the amout of elemtents in 
      # the scores array
      if (@scores == $current_iteration) {
        $result_index = 'error';
        last;
      }

      # see if the score is even between the target score and the upper limit
      if ($score == $random_score) {
        # for now just exit the loop and return
        $result_index = $current_iteration;
        last;
      }

      # count the iteraions of the loop
      $current_iteration++;
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return($result_index);
    
  }

  ##############################################################################
  # _get_random_score subroutine 
  ##############################################################################
  sub _get_random_score {
  
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to function 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $target_score = shift;
    my @scores = @_;
    
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $score_min = 0;
    my $max_avail_score = 0;
    my $min_avail_score = 0;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the highest score available
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    for (@scores) {
      $min_avail_score = $_ if !defined($min_avail_score) || $_ < $min_avail_score;
      $max_avail_score = $_ if !defined($max_avail_score) || $_ > $max_avail_score;
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get a random number with the max being target_score
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # prevent the target score from getting out of scope
    if ($target_score > @scores) {
      $debugger->write("[STRAT]: Targetted score ($target_score) is higher than available scores. Equalizing.");
      $target_score = $max_avail_score;
      $debugger->write("[STRAT]: Target score is now set to $target_score");
    }

    # set a minimal score, we dont want lame strats at high difficulty
    if ($target_score > 5) {
      $debugger->write("[STRAT]: Detected a difficulty higher than 5. Generating minimum score.");
      $score_min = int($target_score - ($target_score / 2));
    }

    # prevent an infinite loop
    if ($score_min > @scores) {
      $debugger->write("[STRAT]: The difficulty: $target_score is too high for generating" .
        " a strategy");
      die "difficulty out of scope";
    }

    # get the random score
    my $random_score = Util::Random::GetRandom($debugger, $target_score, $score_min);

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return($random_score);
  }

  ##############################################################################
  # _shuffle subroutine
  ##############################################################################
  sub _shuffle {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get vars passed to the function
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $deck = shift;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $i = @$deck;

    # randomize the array
    while($i--) {
      my $j = Util::Random::GetRandom($debugger, $i+1);
      @$deck[$i,$j] = @$deck[$j,$i];
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return(@$deck);
  }

  # perl needs this
  1;
}
