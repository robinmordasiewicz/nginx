#!/bin/sh
#

if test -f "/home/marp/.cli/docker-entrypoint"; then
    /home/marp/.cli/docker-entrypoint docs/intro.md --theme spinx-theme/marp-theme.css --allow-local-files --pptx --html false
else
    marp docs/intro.md --theme spinx-theme/marp-theme.css --allow-local-files --pptx --html false
fi

