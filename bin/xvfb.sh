#!/bin/bash
#

export DISPLAY=:99

echo "Remove profile conflicts"
if [ -f .chrome/SingletonLock ]; then
   rm -rf .chrome/Singleton*
fi

if [ -f .chrome/RunningChromeVersion ]; then
   rm -rf .chrome/RunningChromeVersion
fi

if [ -f .chrome/Default/Cookies ];then
   rm -rf .chrome/Default/Cookies
fi

# Turn on virtual frame buffer and fire up chrome
echo "Turn on the virtual frame buffer and run puppeteer after a 10 second delay"
#xvfb-run -n 99 -a --listen-tcp --server-args="-screen 0 1664x936x24 -ac -nolisten tcp -dpi 96 +extension RANDR" "./puppeteer.sh $1 $2" &
#xvfb-run -n 99 -a --listen-tcp --server-args="-screen 0 1664x936x24 -ac -nolisten tcp -dpi 96 +extension RANDR" sleep 10 ; node volterra.js $1 $2 &
#xvfb-run -n 99 -a --listen-tcp --server-args="-screen 0 1664x936x24 -ac -nolisten tcp -dpi 96 +extension RANDR" node distributed-cloud-login.js $1 $2 &
#xvfb-run -n 99 -a --listen-tcp --server-args="-screen 0 1664x936x24 -ac -nolisten tcp -dpi 96 +extension RANDR" node distributed-cloud-login.js $1 $2 &
xvfb-run -n 99 -a --listen-tcp --server-args="-screen 0 1664x936x24 -ac -nolisten tcp -dpi 96 +extension RANDR" icewm &

# Start recording the console
echo "Start recording the virtual frame buffer to screenrecording.mkv for 85 seconds"
# FFREPORT=file=screenrecording.log:level=32
# ffmpeg -v quiet -stats -video_size 1664x936 -r 30 -y -f x11grab -draw_mouse 0 -i :99 -f pulse -c:v libx264rgb -crf 18 -analyzeduration 100M -probesize 400M -tune zerolatency -preset ultrafast -qp 0 -b:v 500k -t 85 screenrecording.mkv &
ffmpeg -v quiet -stats -video_size 1664x936 -r 30 -y -f x11grab -draw_mouse 0 -i :99 -c:v libx264rgb -crf 0 -analyzeduration 100M -probesize 400M -tune zerolatency -preset ultrafast -qp 0 -b:v 500k -t 85 screenrecording.mkv &

node distributed-cloud-login.js $1 $2
echo "Pausing 85 seconds"
sleep 85

echo "run the blacktest filter on screenrecording.mkv"
counter=0
for entry in `ffprobe -f lavfi -i "movie=screenrecording.mkv,blackdetect" -show_entries frame_tags=lavfi.black_start,lavfi.black_end -of default=nw=1 -v quiet`
do
        if [[ $counter == 0 && $entry == 'TAG:lavfi.black_start=0' ]];then
                echo "Black frames detected"
        fi
        if [[ $counter == 1 && $entry =~ "black_end" ]];then
                starting=`echo $entry | cut -f 2- -d "="`
        fi
        if [[ $counter == 2 && $entry =~ "black_start" ]];then
                ending=`echo $entry | cut -f 2- -d "="`
                ending=`echo "scale=4;${ending}-.5" | bc`
        fi
  let counter=$counter+1
done

# Cut off the black frames at the start and end
if [[ -n $starting && -n $ending ]]; then
    echo "trimming black frames off screenrecording.mkv and write output to screenrecording-tmp.mkv"
    ffmpeg -v quiet -stats -y -i screenrecording.mkv -an -vcodec libx264rgb -crf 0 -analyzeduration 100M -probesize 200M -tune zerolatency -preset ultrafast -b:v 500k -filter_complex "[0:v]trim=start=${starting}:end=${ending},setpts=PTS-STARTPTS[v1]" -map [v1] screenrecording-tmp.mkv
fi
mv screenrecording-tmp.mkv screenrecording.mkv

# Get the metadata
echo "getting metadata for screenrecording.mkv and writing to screenrecording.txt"
ffmpeg -v quiet -stats -i screenrecording.mkv -vf:? "signalstats,metadata=print:key=lavfi.signalstats.YAVG:file='screenrecording.txt'" -f null -
paste -d " "  - - < screenrecording.txt > screenrecording.txt.tmp
mv screenrecording.txt.tmp screenrecording.txt

echo "Compare YAVG to find blank frames"
OLDIFS=$IFS; IFS=$'\n'
counter=0
for entry in $(cat screenrecording.txt)
do
   FRAME=`echo $entry | cut -f 1 -d " " | cut -f 2 -d ":"`
   YAVG=`echo $entry | cut -f 2 -d "="`

   if [[ $(echo "${YAVG}>228.7"|bc) -gt 0 || $(echo "${YAVG}==226.695"|bc) -gt 0 || $(echo "${YAVG}==226.684"|bc) -gt 0 || $(echo "${YAVG}==227.682"|bc) -gt 0 || $(echo "${YAVG}==227.693"|bc) -gt 0 || $(echo "${YAVG}==223.697"|bc) -gt 0 || $(echo "${YAVG}==223.696"|bc) -gt 0 || $(echo "${YAVG}==228.692"|bc) -gt 0 || $(echo "${YAVG}==225.376"|bc) -gt 0 || $(echo "${YAVG}==227.865"|bc) -gt 0 ]]; then

      if [ "$counter" -gt 0 ];then
        DROPFRAMES="${DROPFRAMES}+eq(n\,${FRAME})"
      else
        DROPFRAMES="not(eq(n\,${FRAME})"
      fi
      echo "remove Frame:${FRAME} = ${YAVG}"
      let counter=$counter+1
   fi
done

IFS=$OLDIFS
DROPFRAMES="${DROPFRAMES})"
echo ${DROPFRAMES}

# Eliminate blank frames
echo "remove blank frames from screenrecording.mkv and write to screenrecording-processed.mkv"
ffmpeg -v quiet -stats -vsync 0 -y -i screenrecording.mkv -vf "select=${DROPFRAMES},setpts=N/FRAME_RATE/TB" -an -c:v libx264rgb -crf 0 -analyzeduration 100M -probesize 400M -tune zerolatency -preset ultrafast -qp 0 -b:v 500k screenrecording-processed.mkv
mv screenrecording-processed.mkv screenrecording.mkv

## Get the metadata
#echo "get metadata from screenrecording.mkv and write to screenrecording.txt"
#ffmpeg -v quiet -stats -i screenrecording.mkv -vf:? "signalstats,metadata=print:key=lavfi.signalstats.YAVG:file='screenrecording.txt'" -f null -
#paste -d " "  - - < screenrecording.txt > screenrecording.txt.tmp
#mv screenrecording.txt.tmp screenrecording.txt

## Draw overlay information
#echo "Draw overlay onto screenrecording.mkv and write output to screenrecording-overlay.mkv"
#ffmpeg -v quiet -stats -y -i screenrecording.mkv -stats -an -c:v libx264rgb -crf 0 -analyzeduration 100M -probesize 400M -tune zerolatency -preset ultrafast -qp 0 -b:v 500k -filter_complex "[0:v]signalstats,drawtext='fontsize=24:fontcolor=red:text=YAVG\=%{metadata\:lavfi.signalstats.YAVG}':x=100:y=100,drawtext=text= Frame %{n}:x=100:y=150:fontsize=24:fontcolor=red[v]" -map '[v]' -an "screenrecording-overlay.mkv"
# mv screenrecording-overlay.mkv screenrecording.mkv

# sharpen things up
echo "Sharpen video"
ffmpeg -v quiet -stats -y -i screenrecording.mkv -vf unsharp=3:3:1.5 -an -c:v libx264rgb -crf 0 -analyzeduration 100M -probesize 400M -tune zerolatency -preset ultrafast -qp 0 -b:v 500k screenrecording-sharp.mkv
mv screenrecording-sharp.mkv screenrecording.mkv

# convert to mp4
echo "Convert video screenrecording.mkv to compressed screenrecording.mp4"
ffmpeg -v quiet -stats -y -i screenrecording.mkv -an -c:v libx264 -pix_fmt yuv420p screenrecording.mp4

exit 0
