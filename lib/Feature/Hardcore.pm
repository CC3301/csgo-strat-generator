package Feature::Hardcore {

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # import modules
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  use strict;
  use warnings;

  use lib 'lib/';
  use Util::Tools;
  use Util::ReadInventory;

  ##############################################################################
  # GetHardcore subroutine
  ##############################################################################
  sub GetHardcore {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get difficulty
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
    my $debugger = shift;
    my $difficulty = shift;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $hardcore_count = 0;
    my @return = ('none');
    my $counter = 0;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # state vars
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $state_random_fps  = 0;
    my $state_random_sens = 0;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get the list of hardcore settings available
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $settings_list = Util::ReadInventory::Read($debugger, 'hardcore'); 
    my @settings = split "\n", $settings_list;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # generate the hardcore settings
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    # first we need to determine how many hardcore settings should be generated
    if ($difficulty > 20) {
      $hardcore_count = 4;
      shift @return;
      $debugger->write("[HARD] : Running difficulty greater than 20. Generating $hardcore_count hardcore setting(s).");
    } elsif ($difficulty > 15 ) {
      $hardcore_count = 3;
      shift @return;
      $debugger->write("[HARD] : Running difficulty greater than 15. Generating $hardcore_count hardcore setting(s).");
    } elsif ($difficulty > 10 ) {
      $hardcore_count = 2;
      shift @return;
      $debugger->write("[HARD] : Running difficulty greater than 10. Generating $hardcore_count hardcore setting(s).");
    } elsif ($difficulty > 5 ) {
      $hardcore_count = 1;
      shift @return;
      $debugger->write("[HARD] : Running difficulty greater than 5. Generating $hardcore_count hardcore setting(s).");
    } elsif ($difficulty <= 5 ) {
      $debugger->write("[HARD] : Difficulty 5 or lower. Not generating any hardcore setting(s).");
      return(@return);
    }

    # at this point, we know the amout of hardcore settings we want 
    # so we can check if we even have enough
    if ($hardcore_count > @settings) {
      $debugger->write("[HARD] : Failed to generate hardcore settings");
      die "difficulty out of scope";
    }

    # now lets generate the hardcore settings
    until ($counter == $hardcore_count) {

      # generate hardcore setting
      my $current_setting = _generate_hard_core_setting($debugger, @settings);
      
      # make sure we dont duplicate
      foreach(@return) {
        while (substr($_, 0, 10) eq substr($current_setting, 0, 10)) {
          $debugger->write("[HARD] : Found duplicate hardcore setting($current_setting). Regenerating.");
          $current_setting = _generate_hard_core_setting($debugger, @settings);
        }
      }
      
      # filter for some specific settings
      if ($current_setting eq "random_sens" && ! $state_random_sens) {
        my $random_sens = (Util::Random::GetRandom($debugger, $difficulty / 3) / 1.50) / 2 * 2;
        $current_setting = "Random mouse sensivity: $random_sens";
        $state_random_sens = 1;
        $debugger->write("[HARD] : Found random sens setting. Generated random mouse sensivity: $random_sens");
      }
      if ($current_setting eq 'random_fps' && ! $state_random_fps) {
        my $random_fps = _generate_random_fps($debugger, $difficulty);
        while ($random_fps < 60) {
          $random_fps = _generate_random_fps($debugger, $difficulty);
        }
        $current_setting = "Random max_fps setting: $random_fps";
        $state_random_fps = 1;
        $debugger->write("[HARD] : Found random fps setting. Generated random fps: $random_fps");
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
    my $debugger = shift;
    my @settings = @_;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $settings_count = 0; foreach(@settings) { $settings_count++; }
  
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get random int with the max being the size of the settings array
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
    my $random_int = Util::Random::GetRandom($debugger, $settings_count);

    # double check to make sure that we really dont exceed the settings array size
    while($random_int == @settings) {
      $random_int = Util::Random::GetRandom($debugger, $settings_count);
    }

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return($settings[$random_int]);   

  }
  ##############################################################################
  # _generate_random_fps subroutine
  ##############################################################################
  sub _generate_random_fps {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get data passed to function
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $debugger = shift;
    my $difficulty = shift;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $base_int = 25000;
    if ($difficulty < 10) {
      $base_int = 10000;
    }
    if ($difficulty > 20) {
      $difficulty = 20;
    }
    $base_int = $base_int / $difficulty;

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # get random int with some magic
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
    my $random_fps = Util::Random::GetRandom($debugger, $base_int / $difficulty);
    $debugger->write("[HARD] : Generated $random_fps for fps_max setting");

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # return data
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    return($random_fps);   
  }

  # perl needs this
  1;
}
