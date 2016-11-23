# telosBRSSi
RssiHeader.h - includes all the global parameters and message format.

# Code to be deployed on mote connected to laptop
baseStation/BaseStationAppC.nc
baseStation/BaseStationC.nc

# Code to be deployed on other motes
sender/RssiTxAppC.nc
sender/RssiTxC.nc

# How to compile
cd baseStation
make telosb install bsl,/dev/ttyUSBxx
java net.tinyos.tools.PrintfClient -comm serial@/dev/ttyUSBxx:115200

cd sender
make telosb install,xxx
