#!/bin/sh
#

if [ -f diagram2.png ];then
  rm diagram2.png
fi

/usr/local/bin/mmdc -p /puppeteer-config.json -i docs/intro.mmd -o diagram2.png -C mermaid.css -c mermaid-config.json -t neutral

