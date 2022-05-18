
===================================
d2-screenshots2html.sh version 0.06
===================================
show off your character's inventory TODAY!

Installation:
sudo bash install.sh #in linux
bash install.sh #in window 10/11 Cygwin terminal

Uninstallation process:
sudo bash uninstall.sh #in linux
bash uninstall.sh #in windows 10/11 Cygwin terminal

d2-screenshots2html.sh #can be executed from anywhere. No installation needed.
d2-screenshots2html-superquick.sh #needs to be installed so that it can execute d2-screenshots2html.sh in its path 90%sure

the preferred way to use this program is to run
  d2-screenshots2html-superquick.sh
assuming that fails (because it can't find your Screenshots in a "diablo 2 installation path")
you will have to manually copy your Screenshots to an empty.jpg and in/Screenshot*.jpg in
  whatever "workspace" directory you prefer and while in there run:
    d2-screenshots2html.sh


<WINDOWS>
if you install Cygwin and select to install the perl5, bc, ImageMagick packages
  during the Cygwin installation..
your Cygwin terminal needs to be ran as 'root'/admin to call
  bash install.sh
after the install you can revert back to your normal account/user
  terminal.
you can run the Cygwin terminal as admin by right-clicking your
  "Cygwin Terminal" shortcut on your Desktop and selecting
  "Run as administrator"
17-93% tested

<WARNING>
read this whole comment section before running this script.

<BUG>
using screenshots of showing the item stats of switching to your alternate weapons might
  make the program/script weird or make the clipped images bigger than they have to be.

<NOTICE>
I have tested this on Linux and it runs well.
I have 0% tested it on Windows w/Cygwin.

<NOTICE2>
this script uses `perl`, `awk`, `sed`, `paste`, `bc` which is typically included
  with all linux distributions. so you're good.

I'm 90%sure this tool 0 works with Diablo II: Resurrected ScreenShots (because it assumes
  a 800x600 resolution screenshot pretty sure).
  This is vanilla/classic/non-resurrected/LoD/whatever Diablo II only.
  it should work with any mod as well except for changes in resolution.
Although I wonder if it could work with Diablo II: Resurrected if you set its resolution to
  800x600 windowed and pray.

<PRO TIP>
if this script exits prematurely, in your bash-shell/terminal/tty you can go:
echo $?
to see the exit code number. if it's '0' the script probably did a good job.

 use Linux to install/play Diablo II in windowed mode in probably any version
  of WINE you can get. There are a couple routes to get WINE installed.
ou just download the Diablo II and LoD installer from Blizzard's website and then:
d ~/Downloads && wine Diablo_II_Installer_whatever.exe
nce installed you can run/play Diablo II in windowed mode via:
d ~/.wine/drive_c/Program\ Files\ \(x86\)/Diablo II
ine Diablo\ II.exe -w
f you use the XFCE desktop environment you'll need to make sure your alt key works
right: so open/click your start menu, go to Settings, go to Settings Editor
on the left pane click xfwm4
find easy_click on the right and replace "Alt" with an empty string ("")
back story: the window manager in XFCE uses the Alt key to move windows with your
            left-mouse button.

this script requires imagemagick to be installed for the `convert`
  and `composite` command:
<DEBIAN LINUX> sudo apt install imagemagick
<FEDORA LINUX> sudo dnf install ImageMagick

when you hit PrtScr key in Diablo 2 your Screenshots are automatically saved
  to C:\Program Files (x86)\Diablo II\
  (or rather ~/.wine/drive_c/Program\ Files\ \(x86\)/Diablo II)
  naturally. It's a game feature.
Actually in Windows 8 I think the Screenshots are put into a hidden AppData folder
  in your user directory. I hope nobody's using Windows 8 because of that.

to run the script on linux:
d2-screenshot2html-superquick.sh
# OR THE LONG WAY:
mkdir ~/tmp123
cd ~/tmp123
D2_SCREENSHOTS_PATH="$HOME/.wine/drive_c/Program\ Files\ \(x86\)/Diablo II"
mkdir in
mv "$D2_SCREENSHOTS_PATH/ScreenshotTheOneThatHas0CursorSelection.jpg" emptied.jpg
mv "$D2_SCREENSHOTS_PATH"/*.jpg in/
d2-screenshot2html.sh

to run the script on windows with a cygwin terminal:
d2-screenshot2html-superquick.sh
# OR THE LONG WAY:
mkdir ~/tmp123
cd ~/tmp123
D2_SCREENSHOTS_PATH="/cygdrive/c/Program\ Files\ \(x86\)/Diablo II"
mkdir in
mv "$D2_SCREENSHOTS_PATH/ScreenshotTheOneThatHas0CursorSelection.jpg" emptied.jpg
mv "$D2_SCREENSHOTS_PATH"/*.jpg in/
d2-screenshot2html.sh

THIS SCRIPT DOES NOT REQUIRE DIABLO 2 TO BE RUNNING.
it just needs the screenshot JPEGs.

You need a blank emptied.jpg with no mouse/cursor or item selection.
Which is usually your first Screenshot.jpg that you make in-game.
To remove cursor from the screenshot your Diablo II needs to be in
a window not fullscreen. IOW, it's pretty much required to be in windowed mode
for this script to work right.

This script takes about a minute to complete.

1) Do your (item) screenshots on Diablo II with stats and inventory tabs open
   so that no pixels/colors/rgbs change between screenshot JPEGs
