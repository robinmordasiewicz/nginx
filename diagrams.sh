#!/bin/bash
#

if [ -f diagram1.png ];then
  rm diagram1.png
fi

python3 docs/intro-diagram.py
