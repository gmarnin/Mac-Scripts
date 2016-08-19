#!/bin/sh

# Find Cisco Port Discovery (CDP) for a Mac

# Version .2 | 5/2014 | Marnin RU ITS

ComputerName=`/bin/hostname`
ip_en0=`ipconfig getifaddr en0 2>&1`

echo ""
echo "Please be patient as this script can take up to 30 seconds to run...still beats using a Fluke in the field"
echo ""

# en0 is hard coded here
/usr/sbin/tcpdump -nn -v -i en0 -s 1500 -c 1 'ether[20:2] == 0x2000' > /tmp/network.txt


Port=`cat /tmp/network.txt | grep Port-ID | awk '{print $7}' | tr -d "'"`
Vlan=`cat /tmp/network.txt | grep "Native VLAN ID" | awk '{print $9}'`
Physical_location_switch=`cat /tmp/network.txt | grep "Physical Location" | awk '{print $8}'`
Switch_name=`cat /tmp/network.txt | grep "Device-ID" | awk '{print $7}' | tr -d "'"`
Switch_ip=`cat /tmp/network.txt | grep "Management Addresses" | awk '{print $10}'`

echo ""
echo ""
echo "For Mac: $ComputerName"
echo "Mac ip (en0) = $ip_en0"
echo "Port = $Port"
echo "Vlan = $Vlan"
echo "Switch Location = $Physical_location_switch"
echo "Switch Name = $Switch_name"
echo "Switch IP = $Switch_ip"
echo ""
echo ""



exit 0