#!/bin/bash
#set -e
#
##################################################################################################################
# Written to be used on 64 bits computers
# Author 	: 	Erik Dubois
# ArcoLinux	: 	https://arcolinux.info/
##################################################################################################################
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################

#Setting variables
#Let us change the name"
desktop="xfce"

oldname1="iso_name=arcolinux"
newname1="iso_name=arcolinuxb-$desktop"

oldname2='iso_label="arcolinux'
newname2='iso_label="arcolinuxb-'$desktop

echo "Phase 1 : clean up and download the latest ArcoLinux-iso from github"
echo "################################################################## "
echo "Deleting the tmp folder if one exists - takes some time"
[ -d /tmp/git-clone-arcolinux-iso ] && sudo rm -rf /tmp/git-clone-arcolinux-iso
echo "Deleting the build folder if one exists - takes some time"
[ -d ~/byoi-arcolinux-build ] && sudo rm -rf ~/byoi-arcolinux-build
echo "Git cloning files and folder to /tmp/byoi-arcolinux-build"
git clone https://github.com/arcolinux/arcolinux-iso /tmp/git-clone-arcolinux-iso

echo "Phase 2 : Getting the latest updates for some important files"
echo "################################################################## "
echo "Moving to the tmp folder to work"
cd /tmp/git-clone-arcolinux-iso/installation-scripts/
echo "Removing old files/folders from folder"
rm -rf ../archiso/airootfs/etc/skel/.* 2> /dev/null
echo "getting .bashrc from arcolinux-root"
wget https://raw.githubusercontent.com/arcolinux/arcolinux-root/master/root/.bashrc-latest -O ../archiso/airootfs/etc/skel/.bashrc
echo ".bashrc copied to /etc/skel"
echo
#echo "getting oblogout.conf from arcolinux-oblogout-themes"
#wget https://raw.githubusercontent.com/arcolinux/arcolinux-oblogout-themes/master/oblogout.conf.arcolinuxnew -O ../archiso/airootfs/etc/oblogout.conf
#echo "oblogout.conf copied"
echo
echo "getting slim.conf from arcolinux-slimlock-themes"
wget https://raw.githubusercontent.com/arcolinux/arcolinux-slimlock-themes/master/slim.conf.arcolinuxnew -O ../archiso/airootfs/etc/slim.conf
echo "slim.conf copied"
echo
echo "BYOI - getting the files for this specific desktop"
rm ../archiso/packages.both
wget https://raw.githubusercontent.com/arcolinux-byoi/arcolinux-xfce/master/archiso/packages.both -O ../archiso/packages.both
echo "Packages.both copied"
echo "################################################################## "

echo "Phase 3 : Renaming the iso to BYOI and the desktop"
echo "################################################################## "
echo "Let us change the name"

sed -i 's/'$oldname1'/'$newname1'/g' ../archiso/build.sh
sed -i 's/'$oldname2'/'$newname2'/g' ../archiso/build.sh
sed -i 's/'$oldname1'/'$newname1'/g' ../archiso/airootfs/etc/os-release
sed -i 's/'$oldname1'/'$newname1'/g' ../archiso/airootfs/etc/lsb-release

echo "Phase 4 : Let us build the iso"
echo "################################################################## "
echo "Let us change the name"

echo "Checking if archiso is installed"

package="archiso"

#----------------------------------------------------------------------------------

#checking if application is already installed or else install with aur helpers
if pacman -Qi $package &> /dev/null; then

	echo "################################################################"
	echo "################## "$package" is already installed"
	echo "################################################################"

else

	#checking which helper is installed
	if pacman -Qi yaourt &> /dev/null; then

		echo "Installing with yaourt"
		yaourt -S --noconfirm $package

	elif pacman -Qi pacaur &> /dev/null; then

		echo "Installing with pacaur"
		pacaur -S --noconfirm --noedit  $package

	elif pacman -Qi packer &> /dev/null; then

		echo "Installing with packer"
		packer -S --noconfirm --noedit  $package

	fi

	# Just checking if installation was successful
	if pacman -Qi $package &> /dev/null; then

	echo "################################################################"
	echo "#########  "$package" has been installed"
	echo "################################################################"

	else

	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "!!!!!!!!!  "$package" has NOT been installed"
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

	fi

fi



echo "Copying files and folder to ~/byoi-arcolinux-build as root"
sudo mkdir ~/byoi-arcolinux-build
sudo cp -r /tmp/git-clone-arcolinux-iso/* ~/byoi-arcolinux-build

cd ~/byoi-arcolinux-build/archiso


echo "################################################################"
read -p "In order to build an iso we need to clean your cache (y/n)?" choice

	case "$choice" in
 	 y|Y ) sudo pacman -Sc;;
 	 n|N ) echo "Script has stopped. Nothing changed." & exit;;
 	 * ) echo "Type y or n." & echo "Script ended!" & exit;;
	esac


echo "Making the Iso"

sudo ./build.sh -v
