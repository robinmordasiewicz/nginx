#!/bin/bash
#

[ ! -d "html" ] && mkdir html

[ ! -d "theme" ] && mkdir theme
cd theme
git init
git remote add origin https://github.com/robinmordasiewicz/theme.git
git pull origin main
cd -

[ ! -d "docs" ] && mkdir docs
cd docs
git init
git remote add origin https://github.com/robinmordasiewicz/f5-cnf-lab.git
git pull origin main
cd -

cp -aR theme/_static docs/
cp -aR theme/_templates docs/
cp -aR theme/Makefile docs/

docker run --pull=always --name imagemagick --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/imagemagick:latest ./imagemagick.sh
#docker run --pull=always --name diagrams --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/diagrams:latest ./diagrams.sh
#docker run --pull=always --name mermaid-cli --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/mermaid-cli:latest ./mermaid-cli.sh
#docker run --pull=always --name melt --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/melt:latest ./melt.sh
#docker run --pull=always --name sphinx --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/sphinx:latest ./sphinx.sh
#mv docs/_build/html/* html/
docker run --pull=always --name marp-cli --rm -t -v "$PWD":"/home/marp/app" --workdir "/home/marp/app" robinhoodis/marp-cli:latest ./marp-cli.sh

