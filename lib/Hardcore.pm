package Hardcore {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;

  use lib 'lib/';
  use Random;
  use ReadInventory;
  use Debug;

  ##############################################################################
  # GetHardcore subroutine
  ##############################################################################
  sub GetHardcore($) {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get difficulty
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
    my $difficulty = shift;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $hardcore_count = 0;
    my @return = ('none');
    my $counter = 0;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the list of hardcore settings available
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $settings_list = ReadInventory::Read('hardcore'); 
    my @settings = split "\n", $settings_list;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # generate the hardcore settings
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    # first we need to determine how many hardcore settings should be generated
    if ($difficulty > 20) {
      $hardcore_count = 4;
      shift @return;
      Debug::Debug("Running difficulty greater than 20. Generating $hardcore_count hardcore settings.");
    } elsif ($difficulty > 15 ) {
      $hardcore_count = 3;
      shift @return;
      Debug::Debug("Running difficulty greater than 15. Generating $hardcore_count hardcore settings.");
    } elsif ($difficulty > 10 ) {
      $hardcore_count = 2;
      shift @return;
      Debug::Debug("Running difficulty greater than 10. Generating $hardcore_count hardcore settings.");
    } elsif ($difficulty > 5 ) {
      $hardcore_count = 1;
      shift @return;
      Debug::Debug("Running difficulty greater than 5. Generating $hardcore_count hardcore settings.");
    } elsif ($difficulty <= 5 ) {
      Debug::Debug("Difficulty 5 or lower. Not generating any hardcore settings.");
      return(@return);
    }

    # at this point, we know the amout of hardcore settings we want 
    # so we can check if we even have enough
    if ($hardcore_count > @settings) {
      Debug::Debug("Failed to generate hardcore settings");
      die "difficulty out of scope";
    }

    # now lets generate the hardcore settings
    until ($counter == $hardcore_count) {

      # generate hardcore setting
      my $current_setting = _generate_hard_core_setting(@settings);
      
      # make sure we dont duplicate
      foreach(@return) {
        while (substr($_, 0, 10) eq substr($current_setting, 0, 10)) {
          Debug::Debug("Found duplicate hardcore setting($current_setting). Regenerating.");
          $current_setting = _generate_hard_core_setting(@settings);
        }
      }
      
      # filter for some specific settings
      if ($current_setting eq "random_sens") {
        my $random_sens = (Random::GetRandom($difficulty / 3) / 1.25) / 2 * 2;
        $current_setting = "Random mouse sensivity: $random_sens";
        Debug::Debug("Found random sens setting. Generated random mouse sensivity: $random_sens");
      }
      if ($current_setting eq 'random_fps') {
        my $random_fps = int((Random::GetRandom($difficulty * 10) / 0.75 * 1.25));
        $current_setting = "Random max_fps setting: $random_fps";
        Debug::Debug("Found random fps setting. Generated random fps: $random_fps");
      }

      # push the current setting to the return array
      push @return, $current_setting;

      # increment the hardcore setting counter
      $counter++;
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return(@return);

  }

  ##############################################################################
  # _generate_hard_core_setting subroutine
  ##############################################################################
  sub _generate_hard_core_setting {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get data passed to function
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my @settings = @_;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $settings_count = 0; foreach(@settings) { $settings_count++; }
  
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get random int with the max being the size of the settings array
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
    my $random_int = Random::GetRandom($settings_count);

    # double check to make sure that we really dont exceed the settings array size
    while($random_int == @settings) {
      $random_int = Random::GetRandom($settings_count);
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return($settings[$random_int]);   

  }
  1;
}