#!/bin/bash
#

set -e

curl -s -L https://updates.jenkins.io/stable/latestCore.txt --output VERSION


SPHINCBUILDVERSION=`cat VERSION`
`cat VERSION | sed -re "s/^[0-9]+\.[0-9]+\.[0-9]+-*([0-9]*)/\1/" | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}'`

#cat Dockerfile | sed -re "s/FROM.*/FROM jenkins\/jenkins:${JENKINS_VERSION}/" > Dockerfile.tmp && mv Dockerfile.tmp Dockerfile
#cat Dockerfile | sed -re "s/ENV JENKINS_VERSION.*/ENV JENKINS_VERSION `cat VERSION`/" > Dockerfile.tmp && mv Dockerfile.tmp Dockerfile

