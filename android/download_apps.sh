#!/bin/sh
for i in `adb shell pm list packages | grep "$1" | cut -d":" -f2 | sed "s/\\r//g"`
do
  APPDIR=$(adb shell pm path $i | cut -d: -f2 | sed "s/\\r//g")
  adb pull $APPDIR $i.apk
done
