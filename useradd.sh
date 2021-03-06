#!/bin/sh

# --------------------------------
# David Rancourt Jr.
# Copyright (C) 2015
# GPL v3
#
# script usage:
# useradd.sh username "First Last" grouplevel
# --------------------------------

# you may edit the following items to fit your environment
default_staff_groups=('staff')
default_admin_groups=('admin' 'wheel' '502')

# do not edit below this line unless you want to add functionality

if [ "$(id -u)" != "0" ]; then
   echo "Are you sudo? You need to be sudo to run this command."
   exit 1
fi

#echo "Enter user name (no spaces): "
#read -r username

#echo "Enter user's full name (first last): "
#read -r fullname

[ $# -eq 4 ] && { echo "Usage: useradd.sh username fullname-in-quotes grouplevel"; exit 1; }
username=$1
fullname=$2
grouplevel=$3

password=$( cat < /dev/urandom | env LC_CTYPE=C tr -dc '`a-zA-Z0-9\<>!.$%&/()=?|@#[]{}-_,`' | head -c 16)

#randpass() {
#   cat /dev/urandom | env LC_CTYPE=C tr -dc '`a-zA-Z0-9\<>!.$%&/\()=?|@#[]{}-_,` \ | head -c 16; echo "$password"'
#}


#echo "Does this user need Elevated Privs? [y/(N)]"
#read -r "GROUP_ADD"


if [ "$grouplevel" = staff ]; then
   for GRP_STAFF in ${#default_staff_groups[@]}; do
      GROUP_LVL=$GRP_STAFF # for non-admin user add to staff group
   done
elif [ "$grouplevel" = admin ]; then
   for GRP_ADM in ${#default_admin_groups[@]}; do
      GROUP_LVL=$GRP_ADM # for admin user
   done
else
   for GRP_DEF in ${#default_staff_groups[@]}; do
      GROUP_LVL=$GRP_DEF # default setting
   done
fi

#-- check OS X Ver.

OSXVER=$(sw_vers -productVersion | gawk -F '.' '{print $2}' | bc)

#-- check for UID not in use
MAXID=$(dscl . -list /Users UniqueID | awk '{Print $2}' | sort -ug | tail -1)

USRID=$((MAXID+1))

#if 10.10+ run sysadminctl instead of dscl
if [ "$OSXVER" -ge "10" ]; then
   echo "Current System ver is OS X 10.10 or 10.11, using sysadminctl..."
   sysadminctl -addUser "$username" -fullName "$fullname" -UID="$USRID" -password "$password" -home /Users/"$username"
   mkdir /Users/"$username"
   chown -R "$username":staff /Users/"$username"
elif [ "$OSXVER" -ge "7" ]; then  # if OSX Ver is Lion - Mavericks then use dscl
   echo "Current System ver is between 10.7 and 10.9, using dscl..."
   dscl . -create /Users/"$username"
   dscl . -create /Users/"$username" UserShell /bin/bash
   dscl . -create /Users/"$username" RealName "$fullname"
   dscl . -create /Users/"$username" UniqueID "$USRID"
   dscl . -create /Users/"$username" PrimaryGroupID 20
   dscl . -create /Users/"$username" NFSHomeDirectory /Users/"$username"
   dscl . passwd /Users/"$username" "$password"
   #ditto /System/Library/User\ Template/English.lproj /Users/"$username"
   #chown -R $username:staff /Users/$username
   createhomedir -c 2>&1 | grep -v "shell-init"
fi

echo "Adding user to specified groups..."
for GROUP in $GROUP_LVL; do
#if [ "$grouplevel" = admin ]; then
   dseditgroup -o edit -t user -a "$username" "$GROUP"
#elif [ "$grouplevel" = staff ]; then
#   dseditgroup -o edit -t user -a "$username" "$GROUP"
#else
#   dseditgroup -o edit -t user -a "$username" "$GROUP"
#fi
done

echo "Created user $USRID: $username ($fullname) passwd: $password"

exit 0
