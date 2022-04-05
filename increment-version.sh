#!/bin/bash
#

set -e

curl -s -L https://raw.githubusercontent.com/robinmordasiewicz/sphinx-build-container/main/VERSION --output VERSION.sphinx-build-container

SPHINXBUILDVERSION=`cat VERSION.sphinx-build-container | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}'`

cat Jenkinsfile | sed -re "s/^[[:space:]]*robinhoodis\/sphinx-build:.*/sphinx-build:${SPHINXBUILDVERSION}/" > Jenkinsfile.tmp && mv Jenkinsfile.tmp Jenkinsfile

