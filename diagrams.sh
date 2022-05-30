#!/bin/bash
#

if [ -f diagram1.png ];then
  rm diagram1.png
fi

if [ -f docs/diagram1.png ];then
  rm docs/diagram1.png
fi

cd docs && python3 intro-diagram.py && mv diagram1.png ../

