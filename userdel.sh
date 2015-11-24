#!/bin/sh

if [ "$(id -u)" != "0" ]; then
   echo "Are you sudo? You need to be sudo to run this command."
   exit 1
fi

[ $# -eq 2 ] && { echo "Usage: userdel.sh username"; exit 1; }
username=$1

OSXVER=$(sw_vers -productVersion | gawk -F '.' '{print $2}' | bc)

if [ $OSXVER -ge "10" ]; then
   #echo "using sysadminctl as OSX is 10.10.x or 10.11.x"
   sysadminctl -deleteUser "$username"
elif [ $OSXVER -ge "7" ]; then
   #echo "using dscl as OSX is => 10.7 & OSX <= 10.9.x"
   dscl . -delete /User/"$username"
fi

echo "Deleted $username"

exit 0
