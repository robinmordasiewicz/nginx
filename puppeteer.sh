#!/bin/bash
#

sleep 10

if [ -f .chrome/SingletonLock ]; then
   rm -rf .chrome/Singleton*
fi

if [ -f .chrome/RunningChromeVersion ]; then
   rm -rf .chrome/RunningChromeVersion
fi

if [ -f .chrome/Default/Cookies ];then
   rm -rf .chrome/Default/Cookies
fi

node volterra.js ponti8-Sajcyn-hogbih

