This README file contains information on the contents of the
meta-mbed-raspberrypi layer.

The meta-mbed-raspberrypi layer contains mbed_sdcard_image-rpi-class
that can be used to build an SD-card image capable of firmware update. In
practice this means an image with additional partitions and u-boot bootloader.

To use this layer, use the supplied local.conf.sample or add following lines to
your `local.conf`-file:
```
MACHINE = "mbed-rpi3"
KERNEL_IMAGETYPE="uImage"
#ENABLE_UART is strictly not necessary, but can help with debugging issues.
ENABLE_UART="1"
```

# Dependencies

The Mbed Edge is currently tested on top of the Morty-version of the
Yocto. The following repositories are required for the build:

[poky](https://git.yoctoproject.org/cgit/cgit.cgi/poky/)

[meta-openembedded](http://cgit.openembedded.org/meta-openembedded/)

[meta-raspberrypi](https://git.yoctoproject.org/cgit/cgit.cgi/meta-raspberrypi/)

# Adding the meta-mbed-edge layer to your build
In order to use this layer, you need to make the build system aware of
it.

Assuming the meta-mbed-edge layer exists at the top-level of your
yocto build tree, you can add it to the build system by adding the
location of the meta-mbed-edge layer to bblayers.conf, along with any
other layers needed. e.g.:

```
  BBLAYERS ?= " \
    /path/to/yocto/meta \
    /path/to/yocto/meta-poky \
    /path/to/yocto/meta-mbed-raspberrypi \
    /path/to/yocto/meta-mbed-edge \
    "
```
