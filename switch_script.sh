#!/bin/bash

# find Cisco Port Discovery (CDP) from a Mac

# version .4 | 12/2017 | Marnin RU ITS

# check for root privileges
if [ $USER != root ]; then
    echo "Please run script with root privileges, exiting"
    exit 1
fi

ComputerName=`/bin/hostname`

echo ""
echo "If the Ethernet interface is active, this script can take up to 30 seconds to run."
echo "Still beats using a Fluke in the field. Please be patient."
echo ""

# grap the active port. source: https://www.jamf.com/jamf-nation/discussions/18174/ea-to-determine-the-current-network-negotiation-speed
allPorts=$(/usr/sbin/networksetup -listallhardwareports | awk -F' ' '/Device:/{print $NF}')

while read Port; do
    if [[ $(ifconfig "$Port" 2>/dev/null | awk '/status:/{print $NF}') == "active" ]]; then
        ActivePort="$Port"
        ActivePortName=$(/usr/sbin/networksetup -listallhardwareports | grep -B1 "$port" | awk -F': ' '/Hardware Port/{print $NF}')
        break
    fi
done  < <(printf '%s\n' "$allPorts")

if [[ "$ActivePortName" =~ "Ethernet" ]]; then
	LinkSpeed=$(/sbin/ifconfig $ActivePort | awk -F': ' '/media:/{print $NF}'	| grep -o "[0-9]\{1,5\}baseT")
	HardwareAddress=`/sbin/ifconfig $ActivePort | awk '/ether/{print $2}' | head -1`
	MacIP=`/usr/sbin/ipconfig getifaddr $ActivePort 2>&1`

	elif [[ "$ActivePortName" =~ "Wi-Fi" ]]; then
	echo "Wi-Fi is the active port, exiting"
	exit 1

	else
	echo "Not sure what the active network port is, exiting"
	exit 1
fi

# query the switch
/usr/sbin/tcpdump -nn -v -i $ActivePort -s 1500 -c 1 'ether[20:2] == 0x2000' > /tmp/network.txt


Switch_Port=`cat /tmp/network.txt | grep Port-ID | awk '{print $7}' | tr -d "'"`
Vlan=`cat /tmp/network.txt | grep "Native VLAN ID" | awk '{print $9}'`
Physical_location_switch=`cat /tmp/network.txt | grep "Physical Location" | awk '{print $8}'`
Switch_name=`cat /tmp/network.txt | grep "Device-ID" | awk '{print $7}' | tr -d "'"`
Switch_ip=`cat /tmp/network.txt | grep "Management Addresses" | awk '{print $10}'`


echo ""
echo "Mac Results:"
echo "Computer Name: $ComputerName"
echo "Mac IP ($ActivePort) = $MacIP"
echo "Mac, MAC Address = $HardwareAddress"
echo "Link Speed: $LinkSpeed"
echo ""
echo "Switch Results:"
echo "Switch Port = $Switch_Port"
echo "Vlan = $Vlan"
echo "Switch Location = $Physical_location_switch"
echo "Switch Name = $Switch_name"
echo "Switch IP = $Switch_ip"
echo ""
echo ""

exit 0
