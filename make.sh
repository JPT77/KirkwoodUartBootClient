#!/bin/sh
# (C) JPT 2013, licenced under GPLv2

# -Aelf:      on more recent fpc-2.6.0-6 no executable binary is created without. 
#             change for other OS, eg windows.
# -Fusynapse: look in subdirectory synapse for other units. 

echo fpc -Aelf -Fusynapse kirkwooduartboot.pas
     fpc -Aelf -Fusynapse kirkwooduartboot.pas
