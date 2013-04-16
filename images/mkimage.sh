#!/bin/bash
# (C) JPT 2013, licenced under GPLv2

# Be sure to provide a clean kernel image without u-boot header and CRC and without any garbage after kernel end.

MV_DDR_FREQ=533ddr3db
SRC=$1
#SRC=uboot-plain.bin
#SRC=u-boot-${MV_OUTPUT}.bin
DOIMAGE=./doimage
#DOIMAGE=./tools/doimage

echo dd if=uboot-nand of=$SRC skip=1
	 dd if=uboot-nand of=$SRC skip=1

echo $DOIMAGE -T nand  -D 0x600000 -E 0x670000 -P 2048 -R dramregs_${MV_DDR_FREQ}_A.txt $SRC $SRC.${MV_DDR_FREQ}-nand.bin
     $DOIMAGE -T nand  -D 0x600000 -E 0x670000 -P 2048 -R dramregs_${MV_DDR_FREQ}_A.txt $SRC $SRC.${MV_DDR_FREQ}-nand.bin
echo $DOIMAGE -T uart  -D 0x600000 -E 0x670000         -R dramregs_${MV_DDR_FREQ}_A.txt $SRC $SRC.${MV_DDR_FREQ}-uart.bin
     $DOIMAGE -T uart  -D 0x600000 -E 0x670000         -R dramregs_${MV_DDR_FREQ}_A.txt $SRC $SRC.${MV_DDR_FREQ}-uart.bin
echo $DOIMAGE -T flash -D 0x600000 -E 0x670000         -R dramregs_${MV_DDR_FREQ}_A.txt $SRC $SRC.${MV_DDR_FREQ}-flash.bin
     $DOIMAGE -T flash -D 0x600000 -E 0x670000         -R dramregs_${MV_DDR_FREQ}_A.txt $SRC $SRC.${MV_DDR_FREQ}-flash.bin
