#!/bin/bash
#

#melt index.mlt -consumer avformat:index.mp4 f=mp4 s=1920x1080 pix_fmt=yuv420p r=29.97 use_wallclock_as_timestamps=1 enc_time_base=-1

cp theme/index.mlt ./

export XDG_RUNTIME_DIR=/home/ubuntu

if test -f html/index.mp4;then
    rm html/index.mp4
fi

if test -f /usr/bin/dumb-init;then
    /usr/bin/dumb-init -- /usr/bin/xvfb-run -a /usr/local/bin/melt index.mlt -consumer avformat:html/index.mp4 f=mp4 s=1920x1080 pix_fmt=yuv420p r=29.97 use_wallclock_as_timestamps=1 enc_time_base=-1
else
    melt index.mlt -consumer avformat:html/index.mp4 f=mp4 s=1920x1080 pix_fmt=yuv420p r=29.97 use_wallclock_as_timestamps=1 enc_time_base=-1
fi

#melt index.mlt -consumer avformat:output.mov f=mov acodec=pcm_s16le vcodec=libxvid s=1920x1080 b=6000k pix_fmt=uyvy422 vtag=yuvs acodec=pcm_s16le

#melt index.mlt -consumer avformat:output-mlt.mov f=mov acodec=copy vcodec=prores_ks vendor="apl0" s=1920x1080 pix_fmt=yuv420p r=29.97 s=1920x1080
#melt index.mlt -consumer avformat:output-mlt.mp4 f=mov acodec=copy vcodec=prores_ks vendor="apl0" s=1920x1080 pix_fmt=yuv420p r=29.97 s=1920x1080

# -c:v prores_ks -profile:v 2 -vendor apl0 -bits_per_mb 8000 -pix_fmt yuv422p10le -r 29.97 -s 1920x1080 -video_track_timescale 30000
