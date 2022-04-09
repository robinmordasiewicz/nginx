#!/bin/bash
#

set -e

[ -d tmp ] && rm -rf tmp
mkdir tmp
git clone https://github.com/robinmordasiewicz/sphinx.git tmp/
SPHINXBUILDVERSION=`cat tmp/VERSION`
[ -d tmp ] && rm -rf tmp

cat Jenkinsfile | sed -re "s/image:[[:space:]]robinhoodis\/sphinx:.*/image: robinhoodis\/sphinx:${SPHINXBUILDVERSION}/" > Jenkinsfile.tmp && mv Jenkinsfile.tmp Jenkinsfile
