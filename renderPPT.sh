#!/bin/bash
#

[ -d "html" ] && rm -rf html
mkdir html

[ -d "theme" ] && rm -rf theme
mkdir theme
cd theme
git init
git remote add origin https://github.com/robinmordasiewicz/theme.git
git pull origin main
cd -

[ -d "docs" ] && rm -rf docs
mkdir docs
cd docs
git init
git remote add origin https://github.com/robinmordasiewicz/f5-cnf-lab.git
git pull origin main
cd -

cp -aR theme/_static docs/
cp -aR theme/_templates docs/
cp -aR theme/Makefile docs/

./imagemagick.sh
./mermaid-cli.sh
#docker run --pull=always --name diagrams --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/diagrams:latest ./diagrams.sh

./melt.sh
#./sphinx.sh
#mv docs/_build/html/* html/

./marp-cli.sh

