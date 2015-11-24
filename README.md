#OS X User Account management
This script repository is known to work on OS X from 10.8.x to 10.11.x, anything before 10.8.x is not tested, so YMMV.

##useradd.sh usage
`useradd.sh username fullname grouplevel`

* **username**: username with no spaces
* **fullname**: enter user's full name with double quotes ie. `useradd.sh testuser "Test User" admin`
* **grouplevel**: enter either _staff_ or _admin_ which will place user in either group. If left blank, script defaults to _staff_ group.
 * If left blank: `useradd.sh testuser "Test User"` will default to _staff_ group for configured user account.
 * If _admin_ is selected, adds user to _admin_, _wheel_, and _brew_ groups.
##userdel.sh usage
`userdel.sh username`

* **username**: username with no spaces

User account and profile should be removed from the system. The deleted user's UID is not recycled to maintain system integrity.

##useradd.sh notes
Since OS X 10.10 (Yosemite), Apple has used sysadminctl to manage user accounts from the command line. This command does some magic as to user 
attributes that dscl can't do properly. I believe this is due to the System Integrity Check utility included with the operating system (especially 
true in 10.11 (El Capitan))

For all other OS X versions prior to 10.10, the script calls dscl to manage user accounts.

##Have a feature you want to add?
fork the repo and submit a pull request, and I'll take a look at what you've added.

##License
GPL v3.0
