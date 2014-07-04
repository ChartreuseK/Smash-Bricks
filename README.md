# Smash Bricks

Wanting to try my hand at making another game for the pi, I decided to do what the class before mine did, make a breakout clone for the Pi. 
This time instead of doing 1024x768x16 video, I'm doing a more fitting 640x480 with a 256 color palette (the palette is comprised of 16 bit colors). I may try doing some palette switching but it's fairly slow on the Pi currently.


## Prerequisites 

1. Raspberry Pi and Power Cable(I think that's a given)
2. SD Card 
3. Screen that can display a 640x480x16 video signal
4. HDMI (or HDMI to DVI) cable, or Composite cable
6. arm-none-eabi cross compiler toolkit

## Setup

1. The SD card needs to setup with a FAT partition containing the files nessisary to boot the pi, an easy (but bandwidth intensive and requires a 4GB+ card) way is to use the NOOBS installer image on the pi (http://www.raspberrypi.org/documentation/installation/installing-images/README.md) and get it to setup the boot partition. A much smaller way is to grab the files from https://github.com/raspberrypi/firmware/tree/master/boot and put them on the root directory of a FAT formated SD card
2. Run **make**
3. Copy the generated **kernel.img** file to the SD card replacing the existing kernel.img
5. Plug the SD card and HDMI cables into the Pi
6. Power it up




# Author

* Hayden Kroepfl
  * Github (This one) -  [ChartreuseK](https://github.com/ChartreuseK)
  * Email - hkroepfl@ucalgary.ca


