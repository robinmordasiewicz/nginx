#!/bin/bash
#

set -e

#curl -s -L https://raw.githubusercontent.com/robinmordasiewicz/sphinx-container/main/VERSION --output VERSION.sphinx-container

[ -d tmp ] && rm -rf tmp
mkdir tmp
git clone https://github.com/robinmordasiewicz/sphinx-container.git tmp/
#SPHINXBUILDVERSION=`cat tmp/VERSION | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}'`
SPHINXBUILDVERSION=`cat tmp/VERSION`
cat tmp/VERSION
[ -d tmp ] && rm -rf tmp
echo $SPHINXBUILDVERSION

cat Jenkinsfile | sed -re "s/^[[:space:]]*robinhoodis\/sphinx-build:.*/sphinx-build:${SPHINXBUILDVERSION}/" > Jenkinsfile.tmp && mv Jenkinsfile.tmp Jenkinsfile

