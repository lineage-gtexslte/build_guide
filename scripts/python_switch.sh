#!/bin/bash

[ ! -n "$1" ] && echo "No parameter python_version found" && exit
[ -f /usr/bin/python ] && rm /usr/bin/python
if [ $1 -eq 2 ]; then
    ln -s /usr/bin/python2.7 /usr/bin/python
elif [ $1 -eq 3 ]; then
    ln -s /usr/bin/python3.8 /usr/bin/python
else
    echo "An incorrect version of Python was passed. Valid values are 2 or 3."
fi