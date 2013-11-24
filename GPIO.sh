#!/bin/sh

PIN=$1
/usr/local/bin/gpio mode $PIN out
/usr/local/bin/gpio write $PIN 1
sleep 1
/usr/local/bin/gpio write $PIN 0

