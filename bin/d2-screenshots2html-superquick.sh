#!/bin/bash
# quickly move your Screenshots ripped from your Diablo II installation folder
# to a temporary workspace for d2-screenshot2html.sh to do its magic shit.


d2installation_candidate=
if [[ "$(uname -o)" == 'Cygwin' ]]; then
  #awww shit we're on Windows
  d2installation_candidate='/cygdrive/c/Program Files (x86)/Diablo II'
else
  #yay we're on Linux
  if [ -d ~/.wine ]; then
    d2installation_candidate="$HOME/.wine/drive_c/Program Files (x86)/Diablo II"
  elif [ -v WINEPREFIX -a -d "$WINEPREFIX" ]; then
    d2installation_candidate="$WINEPREFIX/drive_c/Program Files (x86)/Diablo II"
  fi
fi

[ -z "$d2installation_candidate" -o ! -d "$d2installation_candidate" ] && {
  echo 'I could not find where your Diablo II installation is. exiting this script.'
  echo 'you will have to execute d2-screenshots2html.sh manually'
  exit 1
}

d2installation="$d2installation_candidate" 
if [ ! -f "$d2installation/Diablo II.exe" ]; then
  echo "So your Diablo II installation @ '$d2installation' doesn't have Diablo II.exe? wtf."
  echo 'exiting script'
  exit 2
fi

screenshot_count="$(find "$d2installation" -maxdepth 1 -type f -name 'Screenshot*.jpg' | wc -l)"
if [[ $screenshot_count -le 1 ]]; then
  echo 'you need at least 2 Screenshot*.jpg in your Diablo II install directory'
  echo "@ $d2installation"
  echo "it looks like you only have $screenshot_count screenshots"
  echo 'exiting script'
  exit 3
fi

echo "found your screenshots @ $d2installation"
echo "all $screenshot_count of them."
echo 'creating a temporary directory/workspace to process the Screenshots into HTML'
tempdir="$(mktemp -d -p $HOME/)"
echo "Remember this: your workspace is @ $tempdir"
cd "$tempdir"
echo "creating directory $tempdir/in"
mkdir in
cd in
echo "moving your $d2installation/Screenshot*.jpg to $tempdir/in/"
mv "$d2installation"/Screenshot*.jpg .
empty_jpg="$(find -maxdepth 1 -type f -name '*.jpg' -printf '%T@ %P\n' | sort | head -1 | awk '{print $2}')"
[ -z "$empty_jpg" ] && { echo "SHIT."; exit 4; }
echo "The Screenshot*.jpg selected to be your empty.jpg is $empty_jpg"
mv "$empty_jpg" ../empty.jpg
cd ..
echo 'executing d2-screenshots2html.sh'
d2-screenshots2html.sh

