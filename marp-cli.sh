#!/bin/sh
#

[ ! -d "html" ] && mkdir html

if test -f "/home/marp/.cli/docker-entrypoint"; then
    /home/marp/.cli/docker-entrypoint docs/index.md --theme spinx-theme/marp-theme.css -o html/index.pptx --allow-local-files --pptx --html false
else
    marp docs/index.md --theme spinx-theme/marp-theme.css --allow-local-files -o html/index.pptx --pptx --html false
fi

