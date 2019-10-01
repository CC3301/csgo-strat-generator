build_binary() {
  
  # use pp to turn csgo.pl into an executable
  cwd=$(pwd)
  pp -I ./lib/ -C -o $cwd/csgo-strat-generator/csgo-strat-generator $cwd/csgo-strat-generator/csgo.pl
  echo "binary built"

}

create_build() {

  # move the required files to a csgo-strat-generator directory 
  cwd=$(pwd)
  mkdir -p $cwd/csgo-strat-generator
  cp -r $cwd/lib $cwd/csgo-strat-generator
  cp -r $cwd/data $cwd/csgo-strat-generator
  cp    $cwd/csgo.pl $cwd/csgo-strat-generator/csgo.pl
  cp -r $cwd/log $cwd/csgo-strat-generator
  cp    $cwd/README.md $cwd/csgo-strat-generator/README.md
  cp    $cwd/LICENSE $cwd/csgo-strat-generator/LICENSE
  echo "copied files"

}

pack_zip() {

  # create a zip file from the csgo-strat-generator directory
  cwd=$(pwd)
  zip -r -9 -q -T csgo-strat-generator.zip ./csgo-strat-generator/
  echo "Zip file created"

}

test_run() {

  # run the script once to see if it works
  cwd=$(pwd)
  cd $cwd/csgo-strat-generator
  perl csgo.pl > ../build.out
  if [ $? != 0 ]; then
    echo "Test failed"
    exit
  fi
  echo "Test complete"
  cd ..

}

cleanup() {

  # remove the csgo-strat-generator directory
  cwd=$(pwd) 
  rm -r $cwd/csgo-strat-generator
  echo "Cleanup complete"

}


# check if the required utilities are installed
pp=$(which pp)
if [ -z $pp ]; then 
  echo "Need PP to function"
  exit
fi
zip=$(which zip)
if [ -z $zip ]; then 
  echo "Need zip to fucntion"
  exit
fi
perl=$(which perl)
if [ -z $perl ]; then 
  echo "Need perl to function"
  exit
fi

# function calls
create_build
test_run
build_binary
pack_zip
cleanup