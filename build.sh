build() {

  pp -x -B -I ./lib/ -A ./data/ -C -o csgo-strat-genertaor csgo.pl

}




pp=$(which pp)
if [ -z $pp ]; then 
  echo "Need PP to function"
  exit
fi
build

