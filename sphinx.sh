#!/bin/bash
#

[ ! -d "html" ] && mkdir html

make -C docs clean html && mv docs/_build/html/* html/
