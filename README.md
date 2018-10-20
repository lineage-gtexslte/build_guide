
# LineageOS 14.1 build guide for the Samsung Galaxy Tab A 7.0 LTE 2016 (SM-T285)

This is a build guide specifically for the Samsung Galaxy Tab A 7.0 LTE 2016 (SM-T285) also known internally and for this guide as the gtexslte
Note that the build is not compatible with the wifi only version also known as the gtexswifi or the (SM-T280)

Operating system and build environment that I used is

OS: Ubuntu 18.04
Processor: Ryzen 3 1300x with 16GB DDR4 ram

You do not need this exact hardware but I am including it for reference purposes. It may be possible to use another linux distro other than ubuntu
however this guide will not cover that.

On the hardware front you do need a lot of disk space, when I mean a lot, I mean 100GB+, you will need to be storing the sources as well
as the compiled binaries and intermediate code. You may also need to store the ROM image which takes at least a gigabyte each

There is also a Docker based build guide in the Misc Section below. Using Docker allows everyone to have a consitent build environment which would make support and debugging easier, aslo it allows for consistent builds even amoung different operating systems. If you are having issues with the main build, I suggest you try the Docker build

## Update Ubuntu

```bash
sudo apt install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev
sudo apt install openjdk-8-jdk
mkdir -p ~/bin
```

Here we prepare our working directory which will be at ~/android/lineage
you can change this, but make sure to account for this change with respect to the instructions from this guide

```bash
mkdir -p ~/android/lineage
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
```

## Download sources

depth=1 and -c options to limit download size, you can omit this if you plan to work on android versions 
and have the time, internet speed and storage to handle this.
However if your goal is just to be able to build lineage 14.1 from source for the gtexslte this is all you need

```bash
cd ~/android/lineage
repo init -u https://github.com/jedld/android.git -b cm-14.1 --depth=1
repo sync -c
```

repo sync will take a while, more like several hours depending on you internet speed. After it is finished you should
be able to see the android project files in the current folder. If there are connection issues or failures you always
execute repo sync again


## Start Build

For Ubuntu 18.04, need to do this first to prevent "Assertion `cnt < (sizeof (_nl_value_type_LC_TIME) / sizeof (_nl_value_type_LC_TIME[0]))' failed" errors

```bash
export LC_ALL=C
```

Setup environment and also make commands like brunch work:

```bash
source build/envsetup.sh
```

Make sure you have enough space on your drive and then start the build. This will take some time, so be patient:

```bash
brunch gtexslte
```

If there are no errors, built intermediate code and binaries will be placed in the out folder. This includes binaries for the host machine (x86) and the device (arm)

You can find the images under out/target/product/gtexslte

adb and the other android commandline tools should also be available, make sure to add them to your path, for example:

```.bashrc
export PATH=/home/jedld/android/lineage/out/host/linux-x86/bin:$PATH
```

This should take effect for a new terminal, you can do:

```bash
source ~/.bashrc
```

so that it takes effect on the current terminal

### Building the kernel

There are still issues with the kernel build integrated into the LineageOS 14.1 build, so you may have to build it again to make it boot properly.


First we create a softlink since there are some paths that the kernel build script expects. Replace ~/android/lineage with the location of where your lineage project folder is.

```
ln -sf ~/android/lineage ~/android-work
```

Start the kernel build

```
cd ~/android/lineage/kernel/gtexslte
./build_kernel.sh
```

After the compile finishes, a new kernel should be built:

kernel/samsung/gtexslte/arch/arm/boot/zImage

Note: If you want to recompile or do a clean build you can do below

```
make mrproper
```

You also have to do the above if you want to start a new lineageos build via brunch

### Creating the boot image

Now we have to create the boot image. Note that everytime you want to update the kernel you have to do both the kernel build and the boot image build.

#### Optional (enable adb on boot)

This is optional, but it may be useful to enable adb logging by default on the device so that you can get logs on first clean boot without going to developer mode.

First edit ~/android/lineage/out/target/product/gtexslte/root/default.prop and at the top of the file you will see this:

```
#
# ADDITIONAL_DEFAULT_PROPERTIES
#
ro.adb.secure=1
ro.device.cache_dir=/cache
ro.secure=1
```

change the secure bits to 0 like this

```
#
# ADDITIONAL_DEFAULT_PROPERTIES
#
ro.adb.secure=0
ro.device.cache_dir=/cache
ro.secure=0
```

This settings will be included in the boot image that will be built in the next step. Note that default.prop changes will require a reflash of the boot image everytime.

#### boot image creation (cont.)

Before starting this make sure that you have paths setup described earlier so that the mkbootfs command is available to you

```bash
mkbootfs ~/android/lineage/out/target/product/gtexslte/root | minigzip > /tmp/boot.img-ramdisk-new.gz

degas-mkbootimg -o ~/android/lineage/out/target/product/gtexslte/boot.img --base 0 --pagesize 2048 \
  --kernel ~/android/lineage/kernel/samsung/gtexslte/arch/arm/boot/zImage --cmdline "console=ttyS1,115200n8" \
  --ramdisk /tmp/boot.img-ramdisk-new.gz --dt ~/android/lineage/kernel/samsung/gtexslte/dt.img \
  --signature ~/android/lineage/device/samsung/gtexslte/seandroid.img
```

After this completes you should have a boot.img ready for flashing. This overwrites the image found in ~/android/lineage/out/target/product/gtexslte

## Build Heimdall

We will use heimdall to flash our gtexslte

```bash
git clone https://gitlab.com/BenjaminDobell/Heimdall.git
sudo apt install build-essential cmake zlib1g-dev qt5-default libusb-1.0-0-dev
```

Go to the Heimdall folder and do the following:

```bash
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make
sudo make install
```

the heimdall command should now be available

### Flash the boot image

Make sure your tablet is fully charged and it is OEM unlocked. (Disable OEM lock by going to Developer Settings)

First if you haven't done so, flash TWRP first:

https://forum.xda-developers.com/galaxy-tab-a/development/recovery-samsung-galaxy-tab-a6-sm-t280-t3475381


TWRP will be useful for wiping your device and flashing gapps later on. If you are coming from another ROM or stock, it might be wise to wipe your device first.

First make sure you are in the correct folder:

```bash
cd ~/android/lineage/out/target/product/gtexslte/
```

Then start the flash

```bash
heimdall flash --KERNEL boot.img --no-reboot
```

The flash will complete although it will just stop and an error will appear, but ignore this and go back to download mode again
by  holding power + HOME + VOL DOWN

Flash the system image

```bash
heimdall flash --SYSTEM system.img
```

Your system should automatically reboot and you should see the LineageOS startup logo instead of the samsung one.

### Troubleshooting

If you did the default.prop edit, you should be able to use adb to check for boot problems. If not you have to go and enable developer mode on your device.

Now, if this is your first time to setup adb you may first need to fix permissions:

```bash
sudo vim /etc/udev/rules.d/51-android.rules
```

For the contents, you can paste the one found here https://github.com/M0Rf30/android-udev-rules/blob/master/51-android.rules

it is updated regularly even for other devices, then restart services so that it takes effect:

```bash
sudo chmod a+r /etc/udev/rules.d/51-android.rules
sudo udevadm control --reload-rules
sudo service udev restart
```

After this you can now do:

```bash
adb logcat
```

If you need a shell you can do:

```bash
adb shell
```

This will allow you to login to the device to explore the filesystem, execute commands and other things

### MISC: building specific modules

You may have fixed a bug or made changes to the lineageos source code, and you want to deploy it to your device. For the most part if the changes only require an update to the system partition an image flash is not necessary.

First compile the module that you made changes with, for example changes where made to the gralloc module:

```bash
cd ~/android/lineage/hardware/sprd/gralloc
mm
```

The mm commmand will compile the current module and place the necessary compiled binaries to ~/android/lineage/out/target/product/gtexslte/system/lib

#### sync updated files to your device

Your devices system folder is readonly by default, we need to make it read/write:

```bash
adb root
adb remount
```

Note: You have to do this everytime your devices is restarted

You can now do this:

```bash
adb sync system
```

All modified files will be copied directly to your device system partition. Changes should take effect once you reboot your device.

## Setup using Docker

First depending on your operating system you need to setup docker. For now this guide focuses on Docker on ubuntu

For ubuntu

```bash
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

sudo apt-get install docker-ce
```

Go to your working directory and clone this project

```bash
git clone https://github.com/lineage-gtexslte/build_guide.git
```

Build the docker image

```bash
cd build_guide
sudo docker build -t gtexslte-builder .
```

Run the convenience script to log into the docker build shell

```bash
./docker_build_run.sh
```

You should see the command prompt. No you can setup the repo:

```bash
root@d83519d06253:/home/android/lineage# repo init -u https://github.com/jedld/android.git -b cm-14.1 --depth=1
root@d83519d06253:/home/android/lineage# repo sync -c
```

Note that "work" folder will be created and where all your build files will be placed.


### MISC: Creating an Odin flashable zip

You might want to share your build, you can create an ODIN flashable package using this script below:

```bash
export BUILD=20181117
cd ~/android/lineage/out/target/product/gtexslte/
rm *.tar
rm *.zip
tar -H ustar -c boot.img system.img > LINEAGE-OMS-14.1-$BUILD-UNOFFICIAL-SMT285-ALPHA.tar
md5sum -t LINEAGE-OMS-14.1-$BUILD-UNOFFICIAL-SMT285-ALPHA.tar >> LINEAGE-OMS-14.1-$BUILD-UNOFFICIAL-SMT285-ALPHA.tar
mv LINEAGE-OMS-14.1-$BUILD-UNOFFICIAL-SMT285-ALPHA.tar LINEAGE-OMS-14.1-$BUILD-UNOFFICIAL-SMT285-ALPHA.tar.md5
gzip -c LINEAGE-OMS-14.1-$BUILD-UNOFFICIAL-SMT285-ALPHA.tar.md5 > LINEAGE-OMS-14.1-$BUILD-UNOFFICIAL-SMT285-ALPHA.zip

```

This will create a zip file that you can share on xda for example.

### Contribution

If you would like to contribute to this guide or report any issues, simple do a pull request or file an issue at https://github.com/lineage-gtexslte/build_guide