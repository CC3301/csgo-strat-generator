package Strats {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;

  use lib 'lib/';
  use ReadInventory;
  use Random;
  use Debug;

  ##############################################################################
  # GetStrat subroutine
  ##############################################################################
  sub GetStrat($) {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # what strat score are we aiming for 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $target_score = shift;
    Debug::Debug("Targetting strat score: $target_score");

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my %strats;
    my $counter = 0;
    my %return;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the list of strats available and store them in a hash 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $strat_list = ReadInventory::Read('strats');
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
        Debug::Debug("Can't continue on malformed data line");
        die();
      }

      # store data in strats hash
      $strats{$counter}{name}  = $strat_name;
      $strats{$counter}{desc}  = $strat_desc;
      $strats{$counter}{score} = $strat_info[1];
    
      # increment the index counter
      $counter++;
    }

    Debug::Debug("Finished processing strategy inventory");

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # tell the score calculation system what kind of score we are aiming for
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $strat_index = _eval_strat_score($counter, $target_score, %strats);

    # check if we even found a strat and if yes, then return the details about
    # this strat
    if ($strat_index eq 'error') {
      $return{name}  = "Anonymus";
      $return{desc}  = "I am sorry, but i didnt find any strat for you";
      $return{score} = 0;
      Debug::Debug("Could not find matching strategy with score");
    } else {
      $return{name}  = $strats{$strat_index}{name};
      $return{desc}  = $strats{$strat_index}{desc};
      $return{score} = $strats{$strat_index}{score};
      Debug::Debug("Found matching strategy with score: " . $return{score});
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return(%return);

  }

  ##############################################################################
  # _eval_strat_score subroutine 
  ##############################################################################
  sub _eval_strat_score {
    
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get passed values
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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

    Debug::Debug("Total strats loaded: $counter");

    # get a random score
    my $random_score = _get_random_score($target_score, @scores);
    while($random_score > @scores) {
      Debug::Debug("Random score too high. Regenerating.");
      $random_score = _get_random_score($target_score, @scores);
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
    my $target_score = shift;
    my @scores = @_;
    
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $score_min = 0;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get a random number with the max being target_score
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # prevent the target score from getting out of scope
    if ($target_score > @scores) {
      Debug::Debug("Targetted score ($target_score) is higher than available strats. Equalizing.");
      $target_score = @scores;
      Debug::Debug("Target score is now set to $target_score");
    }

    # set a minimal score, we dont want lame strats at high difficulty
    if ($target_score > 5) {
      Debug::Debug("Detected a difficulty higher than 5. Generating minimum score.");
      $score_min = int($target_score - ($target_score / 2));
    }

    # prevent an infinite loop
    if ($score_min > @scores) {
      Debug::Debug("The difficulty: $target_score is too high for generating" .
        " a strategy");
      die "difficulty out of scope";
    }

    # get the random score
    my $random_score = Random::GetRandom($target_score, $score_min);

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return($random_score);
  }
  1;
}