#!/usr/bin/perl
use strict;
use warnings;

###############################################################################
# main subroutine
###############################################################################
sub Main() {

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # Get the key the user wants his binds to come out
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $bind_key   = "<key>";
    my $difficulty = $ARGV[0] || 0; 

    #### check for negative difficulty
    if ( $difficulty < 0 ) {
        die("ERR_NEGATIVE_DIFF");
    }

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # other vars 
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my $bind_string     = "bind $bind_key \"";
    my $hardcore_string = "";

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # the table of weapons and their data from which will be chosen randomly
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    my %weapons;

    $weapons{pistols}{0} = ["buy hkp2000; buy glock; "       , "Glock18/USP-S"];
    $weapons{pistols}{1} = ["buy hkp2000; buy glock; "       , "Glock18/USP"];
    $weapons{pistols}{2} = ["buy hkp2000; buy glock; "       , "Glock18/P2000"];
    $weapons{pistols}{3} = ["buy elite; "                    , "Dual Berettas"];
    $weapons{pistols}{4} = ["buy p250; "                     , "P250"];
    $weapons{pistols}{5} = ["buy fiveseven; buy tec9; "      , "Five Seven/Tec9"];
    $weapons{pistols}{6} = ["buy deagle; "                   , "Desert Eagle"];
    $weapons{pistols}{7} = ["buy revolver; "                 , "R8 Revolver"];
    $weapons{pistols}{8} = ["buy fiveseven; buy tec9; "      , "CZ 75 Auto"];

    $weapons{guns}{0}    = ["buy ak47; buy m4a1; "           , "M4A4/AK47"];
    $weapons{guns}{1}    = ["buy ak47; buy m4a1; "           , "M4A1-S/Ak47"];
    $weapons{guns}{2}    = ["buy ak47; buy m4a1; "           , "M4A1/Ak47"];
    $weapons{guns}{3}    = ["buy famas; buy galilar; "       , "Famas/Galil AR"];
    $weapons{guns}{4}    = ["buy ssg08; "                    , "SSG 08"];
    $weapons{guns}{5}    = ["buy aug; buy sg556; "           , "AUG/SG553"];
    $weapons{guns}{6}    = ["buy awp; "                      , "AWP"];
    $weapons{guns}{7}    = ["buy scar20; buy gs3sg1; "       , "SCAR 20/G3SG1"];
    $weapons{guns}{8}    = ["buy mp9; buy mac10; "           , "MP 9/MAC 10"];
    $weapons{guns}{9}    = ["buy mp7; "                      , "MP 7"];
    $weapons{guns}{10}   = ["buy mp7; "                      , "MP 5"];
    $weapons{guns}{11}   = ["buy ump45; "                    , "UMP-45"];
    $weapons{guns}{12}   = ["buy p90; "                      , "P90"];
    $weapons{guns}{13}   = ["buy bizon; "                    , "PP-Bizon"];
    $weapons{guns}{14}   = ["buy nova; "                     , "Nova"];
    $weapons{guns}{15}   = ["buy xm1014; "                   , "XM 1014"];
    $weapons{guns}{16}   = ["buy mag7; buy sawedoff; "       , "MAG 7/Sawed Off"];
    $weapons{guns}{17}   = ["buy m249; "                     , "M249"];
    $weapons{guns}{18}   = ["buy negev; "                    , "Negev"];

    $weapons{nades}{0}   = ["buy incgrenade; buy molotov; "  , "Molotov/Incendiary Grenade"];
    $weapons{nades}{1}   = ["buy decoy; "                    , "Decoy Grenade"];
    $weapons{nades}{2}   = ["buy hegrenade; "                , "HE Grenade"];
    $weapons{nades}{3}   = ["buy smokegrenade; "             , "Smoke Grenade"];
    $weapons{nades}{4}   = ["buy flashbang; buy flashbang; " , "Flashbangs"];

    $weapons{armor}{0}   = [""                               , "No Kevlar"];
    $weapons{armor}{1}   = ["buy vest; "                     , "Just Kevlar"];
    $weapons{armor}{2}   = ["buy vesthelm; "                 , "Kevlar and Helmet"];

    $weapons{defuser}{0} = ["buy defuser; "                  , "Yes"];
    $weapons{defuser}{1} = [""                               , "No"];

    $weapons{taser}{0}   = ["buy taser 34; "                 , "Yes"];
    $weapons{taser}{1}   = [""                               , "No"];

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # generate the game settings
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    #### init vars
    my ($pistol_int, $pistol_use, $armor_int, $armor_use, $gun_int, $gun_use,
        $nade_int1, $nade_int2, $nade_use1, $nade_use2, $defuser_int, $defuser_use,
        $taser_int, $taser_use, $jump_int, $jump_use, $jump_info, $sens_int,
        $rand_sens, $sens_use, $inv_int, $inv_use, $spray_int, $spray_use,
        $move_int, $move_use, $move_info, $move_prob) = undef;

    if ( $difficulty >= 0 ) {
        #### get pistol
        $pistol_int  = _generate_random_int(8);
        $pistol_use  = $weapons{pistols}{$pistol_int}[1];
        $bind_string = $bind_string . $weapons{pistols}{$pistol_int}[0];
    }
    
    if ( $difficulty >= 1 ) {
        #### get armor 
        $armor_int   = _generate_random_int(2);
        $armor_use   = $weapons{armor}{$armor_int}[1];
        $bind_string = $bind_string . $weapons{armor}{$armor_int}[0];
    }

    if ( $difficulty >= 0 ) {
        #### get gun
        $gun_int     = _generate_random_int(18);
        $gun_use     =  $weapons{guns}{$gun_int}[1];
        $bind_string = $bind_string . $weapons{guns}{$gun_int}[0];
    }

    if ( $difficulty >= 1 ) {
        #### get nades
        $nade_int1   = _generate_random_int(4);
        $nade_use1   = $weapons{nades}{$nade_int1}[1];
        $bind_string = $bind_string . $weapons{nades}{$nade_int1}[0];
        
        #### fix duplicated nade issue
        $nade_int2   = _generate_random_int(4);
        while ( $nade_int1 == $nade_int2 ) {
            $nade_int2 = _generate_random_int(4);
        }
        $nade_use2   = $weapons{nades}{$nade_int2}[1];
        $bind_string = $bind_string . $weapons{nades}{$nade_int2}[0];
    }

    if ( $difficulty >= 2 ) {
        #### get defuser
        $defuser_int = _generate_random_int(1);
        $defuser_use = $weapons{defuser}{$defuser_int}[1];
        $bind_string = $bind_string . $weapons{defuser}{$defuser_int}[0];
    }

    if ( $difficulty >= 1 ) {
        #### get taser 
        $taser_int   = _generate_random_int(1);
        $taser_use   = $weapons{taser}{$taser_int}[1];
        $bind_string = $bind_string . $weapons{taser}{$taser_int}[0];
    }
   
    if ( $difficulty >= 3 ) {
        #### jumping or no
        $jump_int    = _generate_random_int(10);
        if ( $jump_int == 8 ) {
            $jump_use        = "no jumping";
            $jump_info       = "(unbind your specifig key)";
            $hardcore_string = $hardcore_string . "unbind space; unbind mwheelup; ";
        } else {
            $jump_use  = "normal";
            $jump_info = ""; 
        }
    }
    
    #### generate a random sensitivity
    if ( $difficulty >= 4 ) {
        #### random sensivity
        $sens_int = _generate_random_int(2);
        if ( $sens_int == 1) {
            $rand_sens = ((rand($difficulty * 10) + 1) / 10);
            $rand_sens = int($rand_sens * 8) / 8;
            $sens_use  = "random ($rand_sens)";
            $hardcore_string = $hardcore_string . "sensitivity $rand_sens; ";
        } else {
            $sens_use  = "current setting";
        }
    }

    #### generate random spray, tap or burst rules
    if ( $difficulty >= 4 ) {
        $spray_int = _generate_random_int(20);
        if ( $spray_int == 3) {
            $spray_use  = "Tap only";
        } elsif ( $spray_int == 6 ) {
            $spray_use  = "Burst only, min. 3 bullets";
        } elsif ( $spray_int == 9 ) {
            $spray_use  = "Spray only, min. 10 bullets or entire mag";
        } elsif ( $spray_int == 12 ) {
            $spray_use  = "Tap and Burst only, Burst min. 3 bullets";
        } elsif ( $spray_int == 15 ) {
            $spray_use  = "Burst and Spray only, Burst min. 3 bullets, Spray min. 10 bullets";
        } elsif ( $spray_int == 18 ) {
            $spray_use  = "Tap and Spray only, Spray min. 10 bullets";
        } else {
            $spray_use  = "normal";
        }
    }

    if ( $difficulty >= 5 ) {
        $inv_int = _generate_random_int(100);
        if ( $inv_int == 88 ) {
            $inv_use  = "inverted y axis"; 
            $hardcore_string = $hardcore_string . "m_pitch -0.022; "; 
        } else {
            $inv_use  = "current setting";
        }
    }

    if ( $difficulty >= 6 ) {
        #### restricted movement for wasd
        $move_prob = 20 - $difficulty;
        if ( $move_prob < 4 ) {
            $move_prob = 4;
        }
        $move_int = _generate_random_int($move_prob);
        if ( $move_int == 1 ) {
            $move_use = "No w/a keys";
            $hardcore_string = $hardcore_string . "unbind w; unbind a; ";
            $move_info = "(unbind your specific key)"
        } elsif ( $move_int == 2 ) {
            $move_use = "No w/d keys";
            $hardcore_string = $hardcore_string . "unbind w; unbind d; ";
            $move_info = "(unbind your specific key)"
        } elsif ( $move_int == 3 ) {
            $move_use = "No s/a keys";
            $hardcore_string = $hardcore_string . "unbind s; unbind a; ";
            $move_info = "(unbind your specific key)"
        } elsif ( $move_int == 4 ) {
            $move_use = "No s/d keys";
            $hardcore_string = $hardcore_string . "unbind s; unbind d; ";
            $move_info = "(unbind your specific key)"
        } else {
            $move_use = 'normal';
            $move_info = '';
        }
    }

    #### print the weapon set and buy command bind
    print "==================================================================\n";

    #### normal settings
    if ( $difficulty >= 0 ) {
        print "Weapon set:\n\n";
        print "Pistol to use    : $pistol_use\n";
        print "Gun to use       : $gun_use\n";
    }

    if ( $difficulty >= 1 ) {
        print "Armor to use     : $armor_use\n";
        print "Grenades to use  : $nade_use1 and $nade_use2\n";
        print "Taser            : $taser_use\n";
    }

    if ( $difficulty >= 2 ) {
        print "Defuse/Rescue Kit: $defuser_use\n";
    }

    $bind_string = $bind_string . "\"";
    print "\nCommand binding:\n";
    print "$bind_string\n";

    #### hardcore settings
    if ( $difficulty >= 3 ) {
        print "\nHardcore settings:\n\n";
    }
    
    ### jumping
    if ( $difficulty >= 3 ) {
        print "Jumping          : $jump_use $jump_info\n";
    }

    ### sensitivity
    if ( $difficulty >=4 ) {
        print "Sensitivity      : $sens_use\n";
        print "Shooting         : $spray_use\n";
    }

    if ( $difficulty >= 5 ) {
        print "Inverted mouse   : $inv_use\n";
    }

    if ( $difficulty >= 6 ) {
        print "Movement         : $move_use $move_info\n";
    }
   
    if ( $difficulty >= 3 ) {
        print "\nCommand to apply hardcore settings:\n";
        print "$hardcore_string\n";
    }
    print "\nDONT SAVE THIS CONFIG WITH THE SAME NAME AS YOUR MAIN CONFIG!\n";
    print "=================================================================\n";
}


###############################################################################
# generate random integer 
###############################################################################
sub _generate_random_int($) {

    my $max = $_[0] + 1;
    my $min = $_[1] || 0;
    
    # new random number generation
    #my $first_rand = int(rand($max/2));
    #my $secon_rand = int(rand($max/2));

    return int(rand($max)) + $min;

}

###############################################################################
# main subroutine call 
###############################################################################
exit(Main());
