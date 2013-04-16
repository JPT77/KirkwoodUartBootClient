#!/bin/bash
# (C) JPT 2013, licenced under GPLv2
BINARY=images/u-boot-1.1.4-netgear.533ddr3db-uart.bin
echo sx -vv -b $BINARY \<$1 \>$1
sx -vv -b $BINARY <$1 >$1


