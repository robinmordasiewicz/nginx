#!/bin/bash
#

export DISPLAY=:99
#sudo Xvfb $DISPLAY -screen 0 1920x1080x24 &
#node volterra.js ponti8-Sajcyn-hogbih &

#xvfb-run --listen-tcp --server-num 99 -s "-ac -screen 0 1920x1080x24" node volterra.js ponti8-Sajcyn-hogbih &

if [ -f .chrome/SingletonLock ]; then
   rm -rf .chrome/Singleton*
fi

xvfb-run -n 99 -a --listen-tcp --server-args="-screen 0 1920x1080x24 -ac -nolisten tcp -dpi 96 +extension RANDR" "./screenrecording.sh" &
ffmpeg -video_size 1920x1080 -y -probesize 200M -f x11grab -draw_mouse 0 -i :99 -pix_fmt yuv420p -codec:v libx264 -r 30 screengrab.mp4 

#sleep 10
#echo 'q' >&"${COPROC[1]}"
