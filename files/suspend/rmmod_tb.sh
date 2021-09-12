#!/bin/sh
if [ "${1}" = "pre" ]; then
  modprobe -r apple_ib_tb
  modprobe -r apple_ib_als
  modprobe -r hid_apple
elif [ "${1}" = "post" ]; then
  modprobe hid_apple
  modprobe apple_ib_als
  modprobe apple_ib_tb
fi
