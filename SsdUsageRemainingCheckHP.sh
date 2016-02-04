#!/bin/bash

function GetSmartArrayNumber(){
	smart_array_number=`hpssacli ctrl all show|grep 'Smart Array'|wc -l`
}
function GetPhysicalDrive(){
/usr/sbin/hpssacli controller all show detail config |grep physicaldrive|awk '{print $2}'|sort|uniq
}
if [ -f /usr/sbin/hpssacli ];then
	hpclicmd='/usr/sbin/hpssacli'
elif [ -f /usr/sbin/hpacucli ];then
	hpclicmd='/usr/sbin/hpacucli'
else
	echo 'hpacucli or hpssacli no found,script exit!'
	exit
fi
smart_array_number=0
GetSmartArrayNumber
for ((slotid=0 ;slotid<$smart_array_number;slotid++))
do
    for physicaldrive in `GetPhysicalDrive`
	do
		checkssd=`$hpclicmd ctrl slot=$slotid pd $physicaldrive show detail|grep -i "Solid State SATA"|wc -l`
#		echo $checkssd
        if [ $checkssd -eq 1 ]
		then
			ssdusageremaining=`$hpclicmd ctrl slot=$slotid pd $physicaldrive show detail|grep -i "Usage remaining"`
			echo -E "physicaldrive $physicaldrive  $ssdusageremaining"
			
		fi
	done
done
