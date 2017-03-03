#!/bin/bash

echo -e "deb http://ftp.de.debian.org/debian-archive/debian/ lenny main non-free contrib\ndeb-src http://ftp.de.debian.org/debian-archive/debian/ lenny main non-free contrib" > /etc/apt/sources.list

apt-get update

apt-get -y install schroot schroot-common

echo -e "deb http://ftp.de.debian.org/debian-archive/debian/ lenny main non-free contrib\ndeb-src http://ftp.de.debian.org/debian-archive/debian/ lenny main non-free contrib\n\ndeb http://ftp.de.debian.org/debian-archive/debian/ squeeze main non-free contrib\ndeb-src http://ftp.de.debian.org/debian-archive/debian/ squeeze main non-free contrib" > /etc/apt/sources.list

apt-get update

apt-get -y install debootstrap

debootstrap wheezy /chroot-wheezy http://ftp.de.debian.org/debian

echo -e '#!/bin/bash\n\napt-get update\n\napt-get -y install openssl libcap2 liblzo2-2 libwrap0 libjansson4 lsof\n\ncd /tmp/\ndpkg -i *.deb\n\nmount -t proc proc /proc\n\n/etc/init.d/bareos-fd restart' > /chroot-wheezy/root/tester.sh
chmod 755 /chroot-wheezy/root/tester.sh

echo -e "deb http://ftp.de.debian.org/debian/ wheezy main non-free contrib\ndeb-src http://ftp.de.debian.org/debian/ wheezy main non-free contrib\n\ndeb http://security.debian.org/ wheezy/updates main contrib non-free\ndeb-src http://security.debian.org/ wheezy/updates main contrib non-free\n\ndeb http://ftp.de.debian.org/debian/ wheezy-updates main contrib non-free\ndeb-src http://ftp.de.debian.org/debian/ wheezy-updates main contrib non-free\n\ndeb http://ftp.de.debian.org/debian/ wheezy-backports main contrib non-free\ndeb-src http://ftp.de.debian.org/debian/ wheezy-backports main contrib non-free\n" > /chroot-wheezy/etc/apt/sources.list

cp /etc/schroot/schroot.conf /etc/schroot/schroot.conf_orig
echo -e '[wheezy-test]\ndescription=CHROOT for BAREOS Agent\ntype=directory\nlocation=/chroot-wheezy\nusers=root' >> /etc/schroot/schroot.conf

cd /chroot-wheezy/tmp/
wget -N http://download.bareos.org/bareos/release/16.2/Debian_7.0/i386/bareos-bconsole_16.2.4-12.1_i386.deb
wget -N http://download.bareos.org/bareos/release/16.2/Debian_7.0/i386/bareos-client_16.2.4-12.1_i386.deb
wget -N http://download.bareos.org/bareos/release/16.2/Debian_7.0/i386/bareos-common_16.2.4-12.1_i386.deb
wget -N http://download.bareos.org/bareos/release/16.2/Debian_7.0/i386/bareos-filedaemon_16.2.4-12.1_i386.deb
wget -N http://download.bareos.org/bareos/release/16.2/Debian_7.0/i386/libfastlz_0.1-7.2_i386.deb
wget -N http://download.bareos.org/bareos/release/16.2/Debian_7.0/i386/libfastlz-dev_0.1-7.2_i386.deb

cd /tmp/
wget -N http://download.bareos.org/bareos/release/16.2/Debian_7.0/i386/bareos-bconsole_16.2.4-12.1_i386.deb
wget -N http://download.bareos.org/bareos/release/16.2/Debian_7.0/i386/bareos-client_16.2.4-12.1_i386.deb
wget -N http://download.bareos.org/bareos/release/16.2/Debian_7.0/i386/bareos-common_16.2.4-12.1_i386.deb
wget -N http://download.bareos.org/bareos/release/16.2/Debian_7.0/i386/bareos-filedaemon_16.2.4-12.1_i386.deb
wget -N http://download.bareos.org/bareos/release/16.2/Debian_7.0/i386/libfastlz_0.1-7.2_i386.deb
wget -N http://download.bareos.org/bareos/release/16.2/Debian_7.0/i386/libfastlz-dev_0.1-7.2_i386.deb

/usr/bin/schroot -c wheezy-test "/root/tester.sh"
