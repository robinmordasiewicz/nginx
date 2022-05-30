#!/bin/bash
#

[ ! -d "sphinx-theme" ] && mkdir sphinx-theme
cd sphinx-theme
git init
git remote add origin https://github.com/robinmordasiewicz/sphinx-theme.git
git pull origin main
cd -

[ ! -d "docs" ] && mkdir docs
cd docs
git init
git remote add origin https://github.com/robinmordasiewicz/f5-cnf-lab.git
git pull origin main
cd -

docker run --pull=always --name imagemagick --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/imagemagick:latest ./imagemagick.sh
docker run --pull=always --name diagrams --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/diagrams:latest ./diagrams.sh
docker run --pull=always --name mermaid-cli --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/mermaid-cli:latest ./mermaid-cli.sh
docker run --pull=always --name marp --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/marp:latest ./marp.sh
docker run --pull=always --name melt --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/melt:latest ./melt.sh
