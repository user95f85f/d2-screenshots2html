#!/bin/bash
# convert ./empty.jpg and in/Screenshot*.jpg into out/* + out/index.html



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


[ -d out ] && { echo bad idea to process with an already created out directory. exiting,; exit 5; }
mkdir out 2> /dev/null
[ -d in ] || { echo 'are you really that stupid?'; exit 2 ;}
[ -f empty.jpg -o -f emptied.jpg ] || { echo 'are you really that stupid?'; exit 3; }
Screenshot_count="$(find in -maxdepth 1 -type f -name '*.jpg' | wc -l)"
[[ $Screenshot_count -eq 0 ]] && { echo 'are you really that stupid?'; exit 4; }

empty_jpeg=''
if [ -f empty.jpg ]; then
  empty_jpeg=empty.jpg
else
  empty_jpeg=emptied.jpg
fi

cd in || exit 6
screenshot_jpegs=*.jpg
[[ -z "$screenshot_jpegs" ]] && exit 7
for i in $screenshot_jpegs ; do
  if [[ ! -f "../out/$i.txt" ]] ; then
    convert "$i" "../out/$i.txt" || exit 8
    sed -si '/^#/d;s/#.*//;s/[,:()]/ /g;s/...$//;s/  */_/g;s/^[0-9]\+_[0-9]\+_//' "../out/$i.txt" || exit 9
  fi
done
cd ../out || exit 10
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
convert ../$empty_jpeg emptied.png #I'm 0%sure why I'm converting it into a PNG
mkdir txts_for_creation_of_emptied && \
mv *.txt txts_for_creation_of_emptied/
n=0
for i in ../in/*.jpg ; do
  let n++
  save_png_as=`printf '%03d_get_crop_and_cursor.png' $n`
  composite -compose subtract $i emptied.png $save_png_as
done

mkdir d2inv_images
cp ../$empty_jpeg d2inv_images/

for i in *.png ; do
  if [[ $i = 'emptied.png' ]] ; then
    continue;
  fi
  convert $i $i.txt
done
sed -si '/^#/d;s/#.*//;s/[,:()]/ /g;s/...$//;s/  */ /g;s/^[0-9]\+ [0-9]\+ //' *.txt


n=0
images_to_crop=../in/*.jpg
echo "<!-- Created by d2_inventory_screenshots_to_html.sh version whatever  --><script>
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
cursor_loc_and_crop_rect=$(perl -Mstrict -Mwarnings -MPOSIX -e '
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
  my @rgb = split / /;
  if($rgb[0] != 0 || $rgb[1] != 0 || $rgb[2] != 0){
    my @xy = get_x_y($line_number);
    #if($rgb[0] >= 246 && $rgb[0] <= 254 &&
    #  $rgb[1] >= 0 && $rgb[1] <= 21 &&
    #  $rgb[2] >= 236 && $rgb[2] <= 254){
    if($rgb[2] > 199){
      push @x, $xy[0];
      push @y, $xy[1];
    }
    #}
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
rect_location_x="$(( $cursor_location_x - $mouse_over_width / 2 ))"
rect_location_y="$(( $cursor_location_y - $mouse_over_height / 2 ))"
echo "<img src=\"d2inv_images/cropped_$n.jpg\" id=\"crop$n\" style=\"position:absolute;left:${crop_x}px;top:${crop_y}px;display:none\"><div class=\"redrect\" style=\"position:absolute;width:${mouse_over_width}px;height:${mouse_over_height}px;left:${rect_location_x}px;top:${rect_location_y}px\" onmouseover=\"document.getElementById('crop$n').style.display='block';change_css('.redrect', 'background-color', 'rgba(255, 0, 0, 0)')\" onmouseout=\"document.getElementById('crop$n').style.display='none';change_css('.redrect', 'background-color', 'rgba(255, 0, 0, 0.3)')\"></div>" >> index.html
done

echo '<img src="d2inv_images/'$empty_jpeg'" width="800" height="600" usemap="#d2char" style="border-style:none"></div>' >> index.html

