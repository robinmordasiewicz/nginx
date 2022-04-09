#!/bin/bash
#

set -e

#curl -s -L https://raw.githubusercontent.com/robinmordasiewicz/sphinx/main/VERSION --output VERSION
#SPHINXBUILDVERSION=`cat tmp/VERSION | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}'`

[ -d tmp ] && rm -rf tmp
mkdir tmp
git clone https://github.com/robinmordasiewicz/sphinx.git tmp/
SPHINXBUILDVERSION=`cat tmp/VERSION`
[ -d tmp ] && rm -rf tmp

echo "Updating Jenkinsfile to image: robinhoodis/sphinx:$SPHINXBUILDVERSION"

cat Jenkinsfile | sed -re "s/image:[[:space:]]robinhoodis\/sphinx:.*/image: robinhoodis\/sphinx:${SPHINXBUILDVERSION}/" > Jenkinsfile.tmp && mv Jenkinsfile.tmp Jenkinsfile
