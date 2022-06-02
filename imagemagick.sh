#!/bin/bash
#

. theme/theme.conf
. docs/index.conf

#convert ${BACKGROUND} -verbose -strip -resize 1920x1080 -quality 100 -density 72x72 -units pixelsperinch tmp.png


convert -size 1920x1080 xc:'#0F487A' tmp.png
convert tmp.png -fill '#F2B819' -stroke '#F2B819' -draw "rectangle 0,1065 1920,1080" yellow.png
convert yellow.png -fill '#DB0021' -stroke '#DB0021' -draw "rectangle 770,1065 1920,1080" yellow-red.png
convert yellow-red.png -fill '#EE593B' -stroke '#EE593B' -draw "rectangle 937,1065 1920,1080" yellow-red-orange.png
convert yellow-red-orange.png -fill '#1C89C9' -stroke '#1C89C9' -draw "rectangle 1265,1065 1920,1080" yellow-red-orange-cyan.png
convert yellow-red-orange-cyan.png -fill '#0E487A' -stroke '#0E487A' -draw "rectangle 1593,1065 1920,1080" yellow-red-orange-cyan-blue.png

convert yellow-red-orange-cyan-blue.png theme/${BACKGROUNDIMAGE} -composite hero-yellow-red-orange-cyan-blue.png

convert -font Arial-Bold -pointsize 96 -fill ${INTROTITLEFONTCOLOR} -annotate +72+445 "${title}" hero-yellow-red-orange-cyan-blue.png title.png
convert -font Arial-Bold -pointsize 96 -fill ${INTROCAPTIONFONTCOLOR} -annotate +72+543 "${caption}" title.png title-caption.png
convert -font Arial-Bold -pointsize 31 -fill ${INTROCAPTIONFONTCOLOR} -annotate +72+660 "${presenter}" title-caption.png title-caption-presenter.png
convert -font Arial-Bold -pointsize 31 -fill ${INTROCAPTIONFONTCOLOR} -annotate +72+728 "${position}" title-caption-presenter.png title-caption-presenter-position.png
convert -font Arial-Bold -pointsize 31 -fill ${INTROCAPTIONFONTCOLOR} -annotate +72+863 "${version}" title-caption-presenter-position.png title-caption-presenter-position-version.png

#convert title-caption-presenter-position-version.png theme/${LOGO} -gravity northeast -geometry 130x130+110+110 -composite intro.png
convert title-caption-presenter-position-version.png theme/${LOGO} -gravity northwest -geometry 95x95+75+75 -composite intro.png
convert yellow-red-orange-cyan-blue.png theme/${LOGO} -gravity center -geometry 380x380-0-19 -composite outro.png

rm yellow.png yellow-red.png yellow-red-orange.png yellow-red-orange-cyan.png yellow-red-orange-cyan-blue.png hero-yellow-red-orange-cyan-blue.png title-caption.png title.png tmp.png title-caption-presenter.png title-caption-presenter-position.png title-caption-presenter-position-version.png
