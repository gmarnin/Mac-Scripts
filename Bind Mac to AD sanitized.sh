#!/bin/sh

# Marnin Goldberg RU NBITS | sanitized 12/2017

# Error when the computer object isn’t pre-created in AD
# dsconfigad: The plugin encountered an error processing request. (10001)

echo
echo "ITS AD Mac Bind Script"
echo "Version Foo"
echo

# Run this script from a local admin account with sudo.

# Check for root
if [ $USER != root ]
then
echo "\n *** Please run script with root privileges, exiting ***\n"
exit 1
fi

# If the machine is already bound to AD, then there's no purpose going any further
check4AD=`/usr/bin/dscl localhost -list . | grep "Active Directory"`

if [ "${check4AD}" != "Active Directory" ]; then
	echo " "
fi
if [ "${check4AD}" = "Active Directory" ]; then
	echo "This Mac is already bound to Active Directory.\nThis script will now exit. "; exit 1
fi

# Confirm the Local HostName, 'M' for Mac
computerid=`/usr/sbin/scutil --get LocalHostName`

# Calculate the computer name length
length=${#computerid}

# Check computer name is less than or equal to 15 characters
if [ "$length" -le "15" ]; then
	echo "HostName being used for for AD is $computerid"
	echo
else
	echo
	echo "Error: Computer name $computerid is more than 15 characters"
	echo "Name must be 15 characters or less, then rerun this script"; exit 1

fi

# Standard bind parameters

# Set time zone and time server
echo "Setting the time:"		
/usr/sbin/systemsetup -settimezone America/New_York
/usr/sbin/systemsetup -setnetworktimeserver domain.rutgers.edu
/usr/sbin/systemsetup -setusingnetworktime on

# Fully qualified DNS name of Active Directory Domain
domain="domain.rutgers.edu"
echo
echo "Enter username of a privileged AD user:"			
read userid
echo
echo "Enter password for the privileged AD user:"			
read -s password
echo

# Advanced options. man dsconfigad for all options and descriptions 
alldomains="enable"			
localhome="enable"			
protocol="smb"				
mobile="enable"				
mobileconfirm="disable"			
useuncpath="enable"			
user_shell="/bin/bash"			
preferred="-nopreferred"		
admingroups="DOMAIN\domain admins,DOMAIN\enterprise admins,DOMAIN\Workstation Administrators"	
packetsign="allow"			
packetencrypt="allow"		
passinterval="14"			
namespace="domain"			

### End of configuration

# Bind to Active Directory
/usr/sbin/dsconfigad -add $domain -username $userid -password $password -computer $computerid -groups "$admingroups" -alldomains $alldomains -localhome $localhome -protocol $protocol -mobile $mobile -mobileconfirm $mobileconfirm -useuncpath $useuncpath -shell $user_shell $preferred -packetsign $packetsign -packetencrypt $packetencrypt -passinterval $passinterval -namespace $namespace

# Restart opendirectoryd (necessary to reload AD plugin activation settings)
/usr/bin/killall opendirectoryd

# Profit 