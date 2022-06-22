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
git remote add origin https://github.com/robinmordasiewicz/contentascode.git
git pull origin main
cd -

cp -aR theme/_static docs/
cp -aR theme/_templates docs/
cp -aR theme/Makefile docs/
cp -aR theme/install-mouse-helper.js ./
cp -a theme/puppeteer-functions.mjs ./
cp -a bin/xvfb.sh ./
cp -a docs/distributed-cloud-login.js ./

 
#docker run --pull=always --name imagemagick --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/imagemagick:latest ./imagemagick.sh
#docker run --pull=always --name diagrams --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/diagrams:latest ./diagrams.sh

##cp -aR theme/.terminalizer ./
##docker run --pull=always --name terminalizer --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/terminalizer:latest ./terminalizer.sh

#docker run --pull=always --name mermaid-cli --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/mermaid-cli:latest ./mermaid-cli.sh
#docker run --pull=always --name melt --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/melt:latest ./melt.sh
#docker run --pull=always --name sphinx --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/sphinx:latest ./sphinx.sh
#mv docs/_build/html/* html/

#docker run --pull=always --name marp-cli --rm -t -v "$PWD":"/home/marp/app" --workdir "/home/marp/app" robinhoodis/marp-cli:latest ./marp-cli.sh

#TOKEN=`kubectl exec --namespace r-mordasiewicz -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password && echo`
#docker run --name puppeteer --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/puppeteer:114 bash -c "node docs/index.js $TOKEN"

docker run --pull=always --name puppeteer --rm -t -v "$PWD":"/home/ubuntu" --workdir "/home/ubuntu" robinhoodis/puppeteer:latest bash -c "./xvfb.sh $1 $2"
rm xvfb.sh install-mouse-helper.js distributed-cloud-login.js puppeteer-functions.mjs
