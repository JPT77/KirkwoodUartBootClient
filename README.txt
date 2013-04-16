You need fpc to compile this project.
Just call ./make.sh

I did not understand the Makefile.fpc concept of lazarus. The Makefile.fpc's I tried did not produce Makefiles that actually build anything.

This project includes: 
- Doimage ELF i386 binary and source provided by Marvell under GPLv2 (from Netgear ReadyNas DuoV2 GPL sources)
- Synapse pascal communication library source release 40 provided by Lukas Gebauer under the license found in the synapse dir.           


You want to see what you are going to download? 
Well, here it is:

$ ./kirkwooduartboot 
Mode parameter is missing.
Usage: /media/DATEN/home/jan/Dokumente/nas/serial/kw/kirkwooduartboot -h -m <mode> -b <baudrate> -d <device>
	-h --help	Print this help.
*	-m --mode <m>	Boot into mode bb (boot from serial via xmodem) or dd (debug console).
	-b --baud	Baudrate. Default 115200.
	-d --device	Device, eg /dev/ttyS0. Default /dev/ttyUSB0
* - Parameter is mandatory.


$ ./kirkwooduartboot  --mode bb --device /dev/ttyUSB0 --baud 115200
Waiting for /dev/ttyUSB0: OK
Open /dev/ttyUSB0: OK
Set Parameters to 115200, 8, N, 1, SoftwareFlow: FALSE, HardwareFlow: FALSE: OK
Clear Recieve Buffer: OK
Sending Command Code BB11223344556677: .0x15 OK. Device is requesting Xmodem transfer now.
Close /dev/ttyUSB0: OK
Starting Xmodem Upload:
sx -vv -b u-boot-1.1.4-netgear-533ddr3db-uart.bin </dev/ttyUSB0 >/dev/ttyUSB0
Sende u-boot-1.1.4-netgear-533ddr3db-uart.bin, 12288 Blöcke:Starten Sie nun Ihr XMODEM-Empfangsprogramm.
Bytes gesendet:1572992   BPS:9666

Übertragung abgeschlossen
Xmodem Upload successfully closed.
Starting Terminal program:
gtkterm
Terminal program successfully closed.

