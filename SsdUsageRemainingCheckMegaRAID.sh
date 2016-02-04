#!/bin/bash

#Megacli64和smartctl命令检查
megaclicmd=`whereis MegaCli64|awk -F":" '{print $2}'|awk '{print $1}'`
smartctlcmd=`whereis smartctl|awk -F":" '{print $2}'|awk '{print $1}'`
if [ -z $megaclicmd ];then
    echo 'Megacli64 no found ,script exit!'
    exit
elif [ -z $smartctlcmd ];then 
    echo 'smartctl no found ,script exit!'
    exit
fi

$megaclicmd -PDList -aALL|grep -E "Slot Number|Device Id|Media Type">/tmp/pdinfo

#检查是否包含SSD硬盘
if [ `cat /tmp/pdinfo|grep -i "Solid State"|wc -l` -eq 0 ];then
    echo "ssd device no found,script exit"
    exit
fi

#获取硬盘信息
for deviceid in `cat /tmp/pdinfo|grep -iEB2 "Solid State"|grep -i "Device Id"|awk -F ":" '{print $2}'`
do

#获取硬盘槽位
    slotid=`cat /tmp/pdinfo|grep -iEB2 "Solid State"|grep -iEB1 $deviceid|grep -i "Slot Number"`
#获取SSD剩余使用寿命百分比
    usage_remaining=`$smartctlcmd -a -d sat+megaraid,$deviceid /dev/sda|grep "Media_Wearout_Indicator"|awk '{print $5}'`
    echo -e "$slotid \t\tusage_remaining: $usage_remaining%"
done
