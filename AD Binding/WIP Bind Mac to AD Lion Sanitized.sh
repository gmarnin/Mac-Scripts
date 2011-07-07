#!/bin/sh

# This script binds Mac OS 10.7.x to the University's Active Directory
# Still need to figure out Kerberos Printing 
echo
echo "Bind Script Lion Testing Version 3.1.14"
# Original by Mike Bombich, bombich.com
# Modified by Marnin Goldberg OIT 7/2011


# Run this script from a local admin account with sudo. Do not use a client's production account!

# If the machine is already bound to AD, then there's no purpose going any further. 
check4AD=`/usr/bin/dscl localhost -list . | grep "Active Directory"`

if [ "${check4AD}" != "Active Directory" ]; then
	echo " "
fi
if [ "${check4AD}" = "Active Directory" ]; then
	echo "This Mac is already bound to Active Directory.\nThis script will now exit. "; exit 1
fi

# Add AD SSO kerberos printing to OS X 
# Start by making the HostName a FQDN

i=$(/usr/sbin/scutil --get LocalHostName) 
k="${i}.domain.edu" 
/usr/sbin/scutil --set HostName $k

computerid=`/usr/sbin/scutil --get LocalHostName`

# Calculate the computer name length
length=${#computerid}

# Check computer name is less than or equal to 15 characters
if [ "$length" -le "15" ]; then
	echo "Computer name used for AD is $computerid"
else
	echo
	echo "Error: Computer name $computerid is more than 15 characters"
	echo "Name must be 15 characters or less, then rerun this script"; exit 1

fi

# Standard parameters
domain="domain.edu"					# fully qualified DNS name of Active Directory Domain
echo
echo "Enter username of a privileged AD user:"			# username of a privileged network user
read userid
echo
PS3="Division Code number:"
echo "Select a Division Code number from the list below:"
select name in OU1 OU2 OU3 TestOU OU4 Other

do
break
done

if [ "$name" = "Other" ]; then
	echo "Enter Division Code:"
	read name
fi

echo "Division Code is $name"
echo "OU=macworkstations,OU=devices,OU=$name,DC=domain,DC=domain,DC=edu"
ou="OU=macworkstations,OU=devices,OU=$name,DC=domain,DC=domain,DC=edu"


# Advanced options
alldomains="enable"			# 'enable' or 'disable' automatic multi-domain authentication
localhome="enable"			# 'enable' or 'disable' force home directory to local drive
protocol="smb"				# 'afp' or 'smb' change how home is mounted from server
mobile="enable"				# 'enable' or 'disable' mobile account support for offline logon
mobileconfirm="disable"			# 'enable' or 'disable' warn the user that a mobile acct will be created
useuncpath="enable"			# 'enable' or 'disable' use AD SMBHome attribute to determine the home dir
user_shell="/bin/bash"			# e.g., /bin/bash or "none"
preferred="-nopreferred"		# Use the specified server for all Directory lookups and authentication # (e.g. "-nopreferred" or "-preferred ad.server.edu")
admingroups="domain\Gui_Computer_Joiners,domain\domain admins,domain\enterprise admins"	# these comma-separated AD groups may administer the machine (e.g. "" or "APPLE\mac admins")
packetsign="allow"			# allow | disable | require
packetencrypt="allow"			# allow | disable | require
passinterval="14"			# number of days
namespace="domain"			# forest | domain


### End of configuration

# Bind to Active Directory
dsconfigad -add $domain -username $userid -computer $computerid -ou "$ou" -groups "$admingroups" -alldomains $alldomains -localhome $localhome -protocol $protocol -mobile $mobile -mobileconfirm $mobileconfirm -useuncpath $useuncpath -shell $user_shell $preferred -packetsign $packetsign -packetencrypt $packetencrypt -passinterval $passinterval -namespace $namespace

# 10.7 bind but shows error "No matching processes were found" Not sure yet which process is causing error. 

# Restart DirectoryService (necessary to reload AD plugin activation settings)
killall DirectoryService


# Adds client account names & location info into the comments field in the computer record in AD
# Script will not work if something is already entered into the comments field for $computerid

# Get list of real user accounts:
listUsers="$(/usr/bin/dscl . list /Users | grep -v _ | grep -v daemon | grep -v nobody | grep -v root | grep -v localadmin | grep -v fakeadmin)"

# For newly imaged Macs with no account
if [ "$listUsers" = "" ]; then
	echo "Enter the primary user netid for this Mac:"		
	read clientid
fi

# Where is this Mac located?
echo "Enter the building and room location for this Mac:"
read location

# Add info into AD
# $ @ the end of $computerid is need for 10.7, otherwise won't work. rdar://9662477
computername="$computerid$" 
/usr/bin/dscl -u $userid -p "/Active Directory/domain/All Domains" -merge "/Computers/$computername" Comment "$listUsers $clientid $location"


# Disable autologin
# defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser
# srm /etc/kcpassword

# Kill loginwindow to return to the login screen
# killall loginwindow

# Destroy this script!
# srm "$0"
