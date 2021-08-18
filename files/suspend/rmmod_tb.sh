#!/bin/sh
if [ "${1}" = "pre" ]; then
  modprobe -r apple_ib_tb hid_apple
elif [ "${1}" = "post" ]; then
  modprobe hid_apple apple_ib_tb
fi
