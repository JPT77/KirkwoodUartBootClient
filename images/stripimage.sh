#!/bin/bash
# (C) JPT 2013, licenced under GPLv2

# removes 512 byte header at the start and 4 byte CRC at the end.
# If you got your image from flash or nand, the image might be larger than the actual kernel. 
# In this case you have to find out yourself where the CRC is located. Good luck!

SIZE=$(ls -l $1|grep -o '[0-9][0-9][0-9][0-9][0-9][0-9]*')
ls -l $1
dd if=$1 of=$1.temp skip=512 bs=1
head -c $(( $SIZE - 4 - 512)) $1.temp > $1.stripped
rm $1.temp
ls -l $1*
