#!/bin/sh

# Version 1.0 3/2016
# Original by Steve Wood @stevewood_tx | modified by Marnin ITS RU
# Source: https://jamfnation.jamfsoftware.com/discussion.html?id=8698 | https://github.com/stevewood-tx/CasperScripts-Public/blob/master/Create%20RDC%20Bookmark/CreateRDC.sh
# Blog post: https://osofrio.wordpress.com/2016/02/29/scripting-remote-desktop-bookmarks/
# Another approach (not used): http://www.macenterprise.org/articles/advanced-rdc-configuration
# Available RDP keys: https://technet.microsoft.com/en-us/library/dn690096.aspx
# What all the keys do: http://www.donkz.nl/files/rdpsettings.html


# Don't need to run as root
# The MS RDP app should be closed when script runs. If open you need to close it and reopen to see this new connection. Add RDP as a blocking app in munki

# grab the logged in user's name
# loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
mostFrequentUser=`/usr/sbin/ac -p | /usr/bin/sort -nrk 2 | awk 'NR == 2 {print $1}'`

# global
RDCPLIST=/Users/$mostFrequentUser/Library/Containers/com.microsoft.rdc.mac/Data/Library/Preferences/com.microsoft.rdc.mac.plist
myUUID=`uuidgen`
defaults='/usr/bin/defaults'

# set variables
connectionName="Connect to Foo"
hostAddress="server:port"

# if you need to put an AD domain name, put it in the userName variable, otherwise leave blank
userName='domain\'
userName+=$mostFrequentUser
#resolution="1280 1024". Use "0 0" for native
resolution="0 0"
colorDepth="32"
fullScreen="false"
scaleWindow="true"
useAllMonitors="true"
# full path needed
application="C:\Windows\system32\calc.exe"


# debug: set -xv; exec 1> /tmp/rdcPlist.txt 2>&1

defaults write $RDCPLIST bookmarkorder.ids -array-add "'{$myUUID}'"
defaults write $RDCPLIST bookmarks.bookmark.{$myUUID}.label -string "$connectionName"
defaults write $RDCPLIST bookmarks.bookmark.{$myUUID}.hostname -string $hostAddress
defaults write $RDCPLIST bookmarks.bookmark.{$myUUID}.username -string $userName
defaults write $RDCPLIST bookmarks.bookmark.{$myUUID}.resolution -string "@Size($resolution)"
defaults write $RDCPLIST bookmarks.bookmark.{$myUUID}.depth -integer $colorDepth
defaults write $RDCPLIST bookmarks.bookmark.{$myUUID}.fullscreen -bool $fullScreen
defaults write $RDCPLIST bookmarks.bookmark.{$myUUID}.scaling -bool $scaleWindow
defaults write $RDCPLIST bookmarks.bookmark.{$myUUID}.useallmonitors -bool $useAllMonitors
defaults write $RDCPLIST bookmarks.bookmark.{$myUUID}.remoteProgram -string "$application"


/usr/sbin/chown -R "$mostFrequentUser:staff" /Users/$mostFrequentUser/Library/Containers/com.microsoft.rdc.mac


# To make testing go faster
# open /Applications/Microsoft\ Remote\ Desktop.app 

