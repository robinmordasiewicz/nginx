#!/bin/sh
#

if [ -f diagram2.png ];then
  rm diagram2.png
fi

mmdc -p /puppeteer-config.json -i docs/index.mmd -o diagram2.png -C theme/mermaid.css -c theme/mermaid-config.json -t neutral

