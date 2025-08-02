# Boot Disk
StudyOS uses a simple 1,44 MiB floppy disk as primary boot disk and filesystem. The build system of StudyOS provides build targets and scripts to generate the boot disk image.

The boot disk consists of three different areas whereby the Master Boot Record with our Stage 1 Bootloader is mandatory for every bootable floppy disk. But the partions and their usage are based on some design decisions I made. The following lists summarizes briefly the major design decisions respectively some requirements:
 * The inital version of StudyOS uses only a simple, single floppy disk
 * The boot process shall contain a Stage 1 and Stage 2 bootloader. Hereby, Stage 1 is the MBR bootloader and Stage 2 is loaded by Stage 1 and does some additional initialization and loads the actual kernel
 * A FAT12 file system is used

Considering the above constraints, I decided to split the boot floppy disk into MBR and two additional partions.

![Boot Disk Layout](../images/Floppy_Partition_Layout.drawio.png)

As the image shows, there are two partitions on the floppy disk. I know, usually there are no paritions on a floppy disk, but this makes the implementation of Stage 1 and Stage 2 bootloader very simple but still pretty flexible.

> [!IMPORTANT]
> The picture uses zero-based indexing of the sectors because the tool `parted`, which I used to create the partitions, uses zero-based sector indexing. The sector adressing with the BIOS uses one-based sector indexing!

The script to generate the boot disk can be found in [Floppy Image Script](../../tools/scripts/generate_floppy.sh). This script uses the tools `dd` and `parted` to create the disk image file and the partition table.

```bash
echo "Generating Image-File with 1,44 MiB"
dd if=/dev/zero of=$1 bs=512 count=2880 >/dev/null

echo "Creating Partition Table"
parted -s $1 mktable msdos
echo "Creating Bootloader Stage 2 Partition"
parted -s $1 -- mkpart primary fat16 1s 256s
echo "Creating Kernel & FAT12 Filesystem Partition"
parted -s $1 -- mkpart primary fat16 257s -1s
#parted -s $1 set on boot 0
fdisk -lu $1
```

The `dd` command is used to create a binary file, filled with zeros in the size of a 1,44 MiB floppy disk. As the commandline parameter for `dd` show, we use a blocksize of 512 Bytes (which corresponds to the size of one disk sector) and a block count of 2880 (which corresponds to the number of sectors on the 1,44 MiB floppy disk).

After the empty disk image has been created, the partition table and the partitions themself are created with `parted`. It is by intention, that there is no filesystem specified. The `generate_floppy.sh` script is just creating a raw image with raw paritions.

The parameter used for `parted` specify the sector start and end numbers for the partitions. Hereby, the alignment is, from the performance perspective, not optimal, but for our purposes it should be fine. This deviation is also reported by `parted` when creating the partitions.

```
[1/1] Generating floppy with a custom command
Generating Image-File with 1,44 MiB
2880+0 records in
2880+0 records out
1474560 bytes (1.5 MB, 1.4 MiB) copied, 0.00559536 s, 264 MB/s
Creating Partition Table
Creating Bootloader Stage 2 Partition
Warning: The resulting partition is not properly aligned for best performance: 1s % 2048s != 0s
Creating Kernel & FAT12 Filesystem Partition
Warning: The resulting partition is not properly aligned for best performance: 257s % 2048s != 0s
Disk boot_floppy.img: 1.41 MiB, 1474560 bytes, 2880 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x3b02f421

Device           Boot Start   End Sectors  Size Id Type
boot_floppy.img1          1   256     256  128K  e W95 FAT16 (LBA)
boot_floppy.img2        257  2879    2623  1.3M  e W95 FAT16 (LBA)

```

## Bootloader Stage 1
The Stage 1 bootloader is located in the Master Boot Record and will be automatically loaded and executed by the BIOS during startup. The MBR is restricted to one sector and therefore the size is limited to 512 Byte. As shown in more detail in the [Bootsector](../development/Bootsector.md) document, the actual available size for bootloader code is only 440 Byte due to additional data like the partition table and other data bytes.

Due to these size limitation of the Stage 1 Bootloader, it only performs a couple of basic initialization steps (see [Stage 1 Bootloader](../components/Bootloader/Stage1.md) for more details) and then loads the Stage 2 bootloader. To make this loading process easy and in some constraints a little more flexible, the Stage 1 bootloader uses the partition table (part of the MBR), to find the correct sector and size of the data it needs to load for Stage 2. That makes it possible to just adapt the Stage 2 partition in size and position, depending on the needs, but leaves the Stage 1 bootloader untouched because all information to load Stage 2 are part of the parition table.

> [!NOTE]
> The current implementation of the Stage 1 Bootloader has a size limitation of 64 KiB for loading Stage 2. This is because of 16 Bit constraints ;-) and kepts the implementation in a first draft pretty simple. I'll fix that later.

## Bootloader Stage 2
The primary task of the Stage 2 bootloader is to switch to Protected-Mode and load the actual OS kernel and start the OS. Hereby, I also took a couple of design decisions respectively set some requirements.
 * The Stage 2 Bootloader is written completely in assembly (just for the challenge and learning more assembly ;-) )
 * It implements, due to Protected-Mode and no BIOS access, some low-level driver for the Floppy Disk, PIT, Video Card for Text-Output and Keyboard
 * It implements a rudimentary FAT12 driver to read the actual OS kernel from a file on the file system partition

As it can be seen, the Stage 2 bootloader has much more things to do compared to Stage 1. But that's OK, because the design leaves around 128 KiB of space to implement everything (in contrast to the 440 Byte for Stage 1 Bootloader).

## Kernel and Filesystem
The Kernel and Filesystem partition contains a regular FAT12 file system where all necessary files for the OS will be stored. This includes also the kernel itself.

I've chosen a FAT12 file system, because it might be the easiest of all FAT implementations.

