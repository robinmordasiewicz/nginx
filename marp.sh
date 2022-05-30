#!/bin/bash
#

if test -f "/home/ubuntu/.cli/docker-entrypoint"; then
    /home/ubuntu/.cli/docker-entrypoint docs/intro.md --theme spinx-theme/marp-theme.css --allow-local-files --pptx --html false
else
    marp docs/intro.md --theme spinx-theme/marp-theme.css --allow-local-files --pptx --html false
fi

