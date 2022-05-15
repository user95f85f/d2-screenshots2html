#!/bin/bash
# d2_inventory_screenshots_to_html.sh version 0.03
#
# <WARNING>
# read this whole comment section before running this script.
#
# <BUG>
# using screenshots of showing the item stats of your secondary weapons might make
#   the program/script buggy.
#
# <NOTICE>
# I haven't ran this script in over 4 years and I only ran it once.
# But it was super successful. So god-speed.
#
# <NOTICE2>
# this script uses `perl`, `awk`, `sed`, `paste`, `bc` which is typically included
#   with all linux distributions. so you're good.
#
# THIS DOES 0 work with Diablo II: Resurrected. This is
#   vanilla/classic/non-resurrected/LoD/whatever Diablo II only.
#
# <POSSIBLE PROBLEM>
# if the mouseover in the HTML offset is a little off try setting the web page's HTML-CSS
# to:    body,html{margin:0;padding:0}
#
# <PRO TIP>
# if this script exits prematurely, in your bash-shell/terminal/tty you can go:
# echo $?
# to see the exit code number. if it's '0' the script probably did a good job.
#
#I use Linux to install/play Diablo II in windowed mode in probably any version
#   of WINE you can get. There are a couple routes to get WINE installed.
#you just download the Diablo II and LoD installer from Blizzard's website and then:
#cd ~/Downloads && wine Diablo_II_Installer_whatever.exe
#once installed you can run/play Diablo II in windowed mode via:
#cd ~/.wine/drive_c/Program\ Files\ \(x86\)/Diablo II
#wine Diablo\ II.exe -w
#if you use the XFCE desktop environment you'll need to make sure your alt key works
# right: so open/click your start menu, go to Settings, go to Settings Editor
# on the left pane click xfwm4
# find easy_click on the right and replace "Alt" with an empty string ("")
# back story: the window manager in XFCE uses the Alt key to move windows with your
#             left-mouse button.
#
# this script requires imagemagick to be installed for the `convert`
#   and `composite` command:
# <DEBIAN LINUX> sudo apt install imagemagick
# <FEDORA LINUX> sudo dnf install ImageMagick
#
# when you hit PrtScr key in Diablo 2 your Screenshots are automatically saved
#   to C:\Program Files (x86)\Diablo II\
#   (or rather ~/.wine/drive_c/Program\ Files\ \(x86\)/Diablo II)
#   naturally. It's a game feature.
#
# what you need to do before running this script:
# mkdir ~/a-place-for-the-script-to-do-its-magic-and-put-its-output
# cd ~/a-place-for-the-script-to-do-its-magic-and-put-its-output
# cp ~/Downloads/d2_inventory_screenshots_to_html-2022.sh .
# D2_SCREENSHOTS_PATH="$HOME/.wine/drive_c/Program\ Files\ \(x86\)/Diablo II"
# mkdir raw-screens
# mv "$D2_SCREENSHOTS_PATH/ScreenshotTheOneThatHas0CursorSelection.jpg" emptied.jpg
# mv "$D2_SCREENSHOTS_PATH"/*.jpg raw-screens/
#
# you run the script with:
# bash d2_inventory_screenshots_to_html-2022.sh
#
# THIS SCRIPT DOES NOT REQUIRE DIABLO 2 TO BE RUNNING.
# it just needs the screenshot JPEGs.
#
# You need a blank emptied.jpg with no mouse/cursor or item selection.
# To remove cursor from the screenshot your Diablo II needs to be in
# a window not fullscreen. IOW, it's pretty much required to be in windowed mode
# for this script to work right.
#
# This script takes more than 8 minutes to complete with 4+ screenshots
# on an Intel i3 1.8 GHz CPU, I'm 48% sure.
#
# 1) Do your item screenshots on Diablo II with stats and inventory tabs open
#    so that no pixels/colors/rgbs change between screenshot JPEGs
# <this script's algorithm>
# using emptied, get the cursor location (I believe based on color/rgb)
# using emptied, get the location/size of what to show of screenshot
#                that is, where to "crop" the item view.
# using 'cursor location' and location/size, create the map HTML MAP line
#   export the cropped image to directory d2inv_images/ as 'cropped_1.jpg ...'
# copy 'emptied.jpg'->'d2inv_images/emptied.jpg'
# convert 'emptied.jpg'->'emptied.png' (probably could just use the jpg)
# create 'index.html' to hold the HTML file that expresses the
#   'd2inv_images/emptied.jpg', the JavaScript for the MAP
#   onmouseover,onmouseout,
#   and using the HTML that would hold the images...


mkdir all-script-out-dump 2> /dev/null

cd raw-screens || exit 2
screenshot_jpegs=*.jpg
[[ -z "$screenshot_jpegs" ]] && exit 3
for i in $screenshot_jpegs ; do 
  if [[ ! -f "../all-script-out-dump/$i.txt" ]] ; then
    convert "$i" "../all-script-out-dump/$i.txt" || exit 4
    sed -si '/^#/d;s/#.*//;s/[,:()]/ /g;s/...$//;s/  */_/g;s/^[0-9]\+_[0-9]\+_//' "../all-script-out-dump/$i.txt" || exit 5
  fi
done
cd ../all-script-out-dump || exit 6
paste -d ' ' *.txt > emptied_predata.dat

echo '# ImageMagick pixel enumeration: 800,600,255,rgb' > emptied_image.txt

perl -MPOSIX -e '
sub get_x_y{
  my $line_num=shift;
  my @out=(0,0);
  $out[1] = floor($line_num / 800);
  $out[0] = $line_num - $out[1] * 800;
  return @out;
}
my $line_number=0;
my $section=0;
my $number_of_shots=0;
my %identity_popularity;
open(FH, "<", "emptied_predata.dat");
open(FH2, ">>", "emptied_image.txt");
while(<FH>){
  chomp;
  $number_of_shots = tr/ // if($number_of_shots == 0);
  for $rgb (split / /){
    $section++;
    if($section > $number_of_shots){
      $section=0;
      $mostpopular=0;
      $mostpopular_identity="";
      for $i (keys %identity_popularity){
        if($identity_popularity{$i} > $mostpopular){
          #if($mostpopular == 1){
          #  print "A mostpopular is a 1???????\n";
          #}
          $mostpopular=$identity_popularity{$i};
          $mostpopular_identity=$i;
        }
      }
      my @position = get_x_y($line_number);
      my @rgb_list = split /_/, $mostpopular_identity;
      printf FH2 "%d,%d: (%3d,%3d,%3d)\n", @position, @rgb_list;
      $line_number++;
      %identity_popularity = undef;
    }

    $identity_popularity{$rgb}++;
  }
}
'
convert ../emptied.jpg emptied.png #I'm 0%sure why I'm converting it into a PNG
mkdir txts_for_creation_of_emptied && \
mv *.txt txts_for_creation_of_emptied/
n=0
for i in ../raw-screens/*.jpg ; do 
  let n++
  save_png_as=`printf '%03d_get_crop_and_cursor.png' $n`
  composite -compose subtract $i emptied.png $save_png_as
done

mkdir d2inv_images
cp ../emptied.jpg d2inv_images/

for i in *.png ; do
  if [[ $i = 'emptied.png' ]] ; then
    continue;
  fi
  convert $i $i.txt
done
sed -si '/^#/d;s/#.*//;s/[,:()]/ /g;s/...$//;s/  */ /g;s/^[0-9]\+ [0-9]\+ //' *.txt


n=0
images_to_crop=../raw-screens/*.jpg
echo "<!-- Created by d2_inventory_screenshots_to_html.sh version 0.03  --><script>
function change_css(classname,element,value) 
{
  var cssRules;
  var added = false;
  for (var S = 0; S < document.styleSheets.length; S++){
    if (document.styleSheets[S]['rules']) {
      cssRules = 'rules';
    } else if (document.styleSheets[S]['cssRules']) {
      cssRules = 'cssRules';
    } else {
      return;
    }

    for (var R = 0; R < document.styleSheets[S][cssRules].length; R++) 
    {
      if (document.styleSheets[S][cssRules][R].selectorText == classname) {
        if(document.styleSheets[S][cssRules][R].style[element]){
          document.styleSheets[S][cssRules][R].style[element] = value;
          added=true;
          break;
        }
      }
    }
    if(!added)
    {
      try{
        document.styleSheets[S].insertRule(classname+' { '+element+': '+value+'; }',document.styleSheets[S][cssRules].length);
      } catch(err){
        try{document.styleSheets[S].addRule(classname,element+': '+value+';');}catch(err){}
      }
    }
  }
}
</script>
<style>
.redrect{background-color:rgba(255, 0, 0, 0.3)}
</style>
<div style=\"position:relative\">" > index.html
for i in *.txt ; do
let n++
cursor_loc_and_crop_rect=$(perl -MPOSIX -e '
sub get_x_y{
  my $line_num=shift;
  my @out=(0,0);
  $out[1] = floor($line_num / 800);
  $out[0] = $line_num - $out[1] * 800;
  return @out;
}
my $line_number=0;
my @x;
my @y;
my $x_min=799;
my $y_min=599;
my $x_max=0;
my $y_max=0;
open(FH, "<", $ARGV[0]);
while(<FH>){
  chomp;
  @rgb = split / /;
  if($rgb[0] != 0 || $rgb[1] != 0 || $rgb[2] != 0){
    @xy = get_x_y($line_number);
    if($rgb[0] >= 246 && $rgb[0] <= 254 && 
      $rgb[1] >= 0 && $rgb[1] <= 21 &&
      $rgb[2] >= 236 && $rgb[2] <= 254){
      push @x, $xy[0];
      push @y, $xy[1];
    }
    $x_min = $xy[0] if($xy[0] < $x_min);
    $y_min = $xy[1] if($y_min == 599);
    $x_max = $xy[0] if($xy[0] > $x_max);
    $y_max = $xy[1] if($xy[1] > $y_max);
  }
  $line_number++;
}
@x = sort {$a <=> $b} @x;
@y = sort {$a <=> $b} @y;
print $x[floor($#x/2)] . " " . $y[floor($#y/2)] . " $x_min $y_min $x_max $y_max" . "\n";
' $i)
crop_x=`echo "$cursor_loc_and_crop_rect" | awk '{print $3}'`
crop_y=`echo "$cursor_loc_and_crop_rect" | awk '{print $4}'`
crop_width=`echo "$cursor_loc_and_crop_rect" | awk "{print \\$5, \" - $crop_x\"}" | bc`
crop_height=`echo "$cursor_loc_and_crop_rect" | awk "{print \\$6, \" - $crop_y\"}" | bc`
convert -crop ${crop_width}x$crop_height+$crop_x+$crop_y `echo $images_to_crop | awk "{print \\$$n}"` -quality 70 d2inv_images/cropped_$n.jpg
mouse_over_width=37
mouse_over_height=30
cursor_location_x=`echo "$cursor_loc_and_crop_rect" | awk '{print $1}'`
cursor_location_y=`echo "$cursor_loc_and_crop_rect" | awk '{print $2}'`
rect_location_x=`echo $cursor_location_x - $mouse_over_width / 2 | bc`
rect_location_y=`echo $cursor_location_y - $mouse_over_height / 2 | bc`
echo "<img src=\"d2inv_images/cropped_$n.jpg\" id=\"crop$n\" style=\"position:absolute;left:${crop_x}px;top:${crop_y}px;display:none\"><div class=\"redrect\" style=\"position:absolute;width:${mouse_over_width}px;height:${mouse_over_height}px;left:${rect_location_x}px;top:${rect_location_y}px\" onmouseover=\"document.getElementById('crop$n').style.display='block';change_css('.redrect', 'background-color', 'rgba(255, 0, 0, 0)')\" onmouseout=\"document.getElementById('crop$n').style.display='none';change_css('.redrect', 'background-color', 'rgba(255, 0, 0, 0.3)')\"></div>" >> index.html
done

echo '<img src="d2inv_images/emptied.jpg" width="800" height="600" usemap="#d2char" style="border-style:none"></div>' >> index.html

