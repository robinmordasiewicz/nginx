#!/bin/bash
#

set -e

[ -d tmp ] && rm -rf tmp
mkdir tmp
git clone https://github.com/robinmordasiewicz/sphinx.git tmp/
SPHINXBUILDVERSION=`cat tmp/VERSION`
[ -d tmp ] && rm -rf tmp

cat Jenkinsfile | sed -re "s/image:[[:space:]]robinhoodis\/sphinx:.*/image: robinhoodis\/sphinx:${SPHINXBUILDVERSION}/" > Jenkinsfile.tmp && mv Jenkinsfile.tmp Jenkinsfile

LOCALREVISION=`cat VERSION | sed -re "s/^[0-9]+\.[0-9]+\.[0-9]+-*([0-9]*)/\1/" | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}'`

echo "${SPHINXBUILDVERSION}-${LOCALREVISION}" > VERSION

