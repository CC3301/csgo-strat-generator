# csgo-strat-generator

**This script is going to fuck up you csgo game if you can't take it as fun.**

This is written in Perl and should work corss-platform, since it
doesn't use any external modules.

## Usage

- If you are on Linux:
  use the perl-packager version by just running
    *"./csgo-strat-gen"*
  from the command line. You might have to make
  it executable tho.
  
- If you are on Linux 2.0:
  use perl itself, make the .pl file excutable
  and run it like this
    *"./csgo-strat-gen.pl"*

- If you are on Windows:
  Run it with the perl interpreter like this
    *"perl csgo-strat-gen.pl"*.
  Everything else is untested.
  
- The difficulty is passed as an command line argument

## Difficulty

  There are difficulty levels 1..6, however there is no
  upper limit.
  
  Until the 'highest' difficulty there are new options
  being added which each stage, everything bigger than 5
  just fucks with some of the probability parameters.
  As i said there is no upper limit, go for a thousand if
  you can turn your mouse down to 1 DPI.
  
### difficulty levels

1. generates a set of pistol and gun to use
1. difficulty 0 and armor, nades and taser
1. difficulty 1 and defuse or rescue kit
1. difficulty 2 and jumping setting
1. difficulty 3 and random sensivity and shooting properties
1. difficulty 4 and inverted mouse
1. difficulty 5 and movement restrictions

**Have fun and remember to *NOT* overwrite your main config.**
