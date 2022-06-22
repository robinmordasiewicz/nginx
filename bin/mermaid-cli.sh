#!/bin/sh
#

if [ -f diagram2.png ];then
  rm diagram2.png
fi

if [ -f /puppeteer-config.json ];then
  mmdc -p /puppeteer-config.json -i docs/index.mmd -o diagram2.png -C theme/mermaid.css -c theme/mermaid-config.json -t neutral
else
  mmdc -i docs/index.mmd -o diagram2.png -C theme/mermaid.css -c theme/mermaid-config.json -t neutral
fi

