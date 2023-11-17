# Simple build with Docker
**_We tried to simplify the assembly as much as possible and hid most of the commands in pre-prepared scripts. If you want to understand the assembly process in more detail, return to the instructions for assembling on a local machine._**

First depending on your operating system you need to install and setup docker. You can find out how to install it [here](https://docs.docker.com/engine/install/).

In the next step, go to your working directory and clone this project:

```bash
git clone https://github.com/lineage-gtexslte/build_guide.git
```

Build the docker image and run container with script:

```bash
./docker_build_run.sh
```

## Build (Step 1)

You should see the command prompt of the created container. Now you can:\
Run the script and go to [step 2](#build--step-2-)
```bash
just_do_it_1
```
or run the instructions yourself.

1. Initialize and sync the repo with scripts:

```bash
root@d83519d06253:/home/android/lineage# repo_init
root@d83519d06253:/home/android/lineage# repo_sync -c
```

*Note that _"work"_ folder will be created and where all your build files will be placed.

2. In the next step, we need set up environment and also make commands like brunch work:

```bash
source build/envsetup.sh
```

3. And start the build (_Make sure you have enough space on your drive_):

```bash
brunch gtexslte
```

If there are no errors, built intermediate code and binaries will be placed in the out folder. This includes binaries for the host machine (x86) and the device (arm). You can find the images under _"out/target/product/gtexslte"_.\
In this case, you can go straight to [step 3](#creating-an-odin-flashable-file--step-3-)

## Build (Step 2)

If you receive an error:

```bash
building image from target_files RECOVERY...
  running:  mkbootfs -f /tmp/targetfiles-rovM6K/META/recovery_filesystem_config.txt /tmp/targetfiles-rovM6K/RECOVERY/RAMDISK
  running:  minigzip
  running:  /home/android/lineage/out/host/linux-x86/bin/mkbootimg --kernel /tmp/targetfiles-rovM6K/RECOVERY/kernel --cmdline console=ttyS1,115200n8 buildvariant=userdebug --base 0 --pagesize 2048 --os_version 7.1.2 --os_patch_level 2018-12-05 --ramdisk /tmp/tmpyFiucF --output /tmp/tmpKkbrSM
Traceback (most recent call last):
  File "./build/tools/releasetools/add_img_to_target_files", line 554, in <module>
    main(sys.argv[1:])
  File "./build/tools/releasetools/add_img_to_target_files", line 548, in main
    AddImagesToTargetFiles(args[0])
  File "./build/tools/releasetools/add_img_to_target_files", line 456, in AddImagesToTargetFiles
    OPTIONS.input_tmp, "RECOVERY", two_step_image=True)
  File "/home/android/lineage/build/tools/releasetools/common.py", line 669, in GetBootableImage
    info_dict, has_ramdisk, two_step_image)
  File "/home/android/lineage/build/tools/releasetools/common.py", line 529, in _BuildBootableImage
    p = Run(cmd, stdout=subprocess.PIPE)
  File "/home/android/lineage/build/tools/releasetools/common.py", line 113, in Run
    return subprocess.Popen(args, **kwargs)
  File "/usr/lib/python2.7/subprocess.py", line 394, in __init__
    errread, errwrite)
  File "/usr/lib/python2.7/subprocess.py", line 1047, in _execute_child
    raise child_exception
OSError: [Errno 2] No such file or directory
make: *** [build/core/Makefile:1973: /home/android/lineage/out/target/product/gtexslte/obj/PACKAGING/target_files_intermediates/lineage_gtexslte-target_files-956ebe74d0.zip] Error 1
make: *** Deleting file '/home/android/lineage/out/target/product/gtexslte/obj/PACKAGING/target_files_intermediates/lineage_gtexslte-target_files-956ebe74d0.zip'
make: Leaving directory '/home/android/lineage'
```
then everything is fine too. There are still issues with the kernel build integrated into the LineageOS 14.1 build, so you may have to build it again to make it boot properly.\
To do this, you can use script and go to [step 4](#receiving-firmware-files--step-4-).
```bash
just_do_it_2
```
or run the instructions yourself.

1. Start the kernel build:

```bash
build_kernel
```

2. Now we have to create the boot image:

```bash
create_boot_image
```

_Note: that every time you want to update the kernel you have to do both the kernel build and the boot image build._

## Creating an Odin flashable file (Step 3)

Use: 

```bash
create_flashable_zip
```

## Receiving firmware files (Step 4)
After execution, you will be able to find the files:
* _LINEAGE-OMS-14.1-20231109-UNOFFICIAL-SMT285-ALPHA.tar.md5_ - for Odin 
* _LINEAGE-OMS-14.1-20231109-UNOFFICIAL-SMT285-ALPHA.zip_ - zip file with Boot and System images

in the _"out/target/product/gtexslte"_ folder.

## MISC:

### Using CCache
After starting the Docker container, but before running all scripts, you can configure ccache.
This can help speed up the build if you have excess space.

```bash
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
```

Then, specify the maximum amount of disk space you want ccache to use by typing this:

```bash
ccache -M 50G
```

where 50G corresponds to 50GB of cache. This needs to be run once. Anywhere from 25GB-100GB will result in very noticeably increased build speeds (for instance, a typical 1hr build time can be reduced to 20min). If you’re only building for one device, 25GB-50GB is fine. If you plan to build for several devices that do not share the same kernel source, aim for 75GB-100GB. This space will be permanently occupied on your drive, so take this into consideration.

You can also enable the optional ccache compression. While this may involve a slight performance slowdown, it increases the number of files that fit in the cache. To enable it, run:
```bash
ccache -o compression=true
```