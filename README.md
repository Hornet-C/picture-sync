# picture-sync
This repository contains a set of scripts to synchronize a (Canon) DSLR-cameras pictures, with help of a raspberry pi, to another computer. It should work with any [gphotofs](https://github.com/gphoto/gphotofs) compatible camera.

The content of the SD-card is mirrored, so if you delete a photo on the camera, the photo will also be deleted in the destination folder. For my setup I use [rsync](https://linux.die.net/man/1/rsync) and [ssh](https://linux.die.net/man/1/ssh) to synchronize without a password.

This repository contains:

*  an [ansible](https://www.ansible.com/) role to configure the raspberrys
  - locale
  - hostname
  - keyboard setup
  - WiFi setup
  - [dynv6](https://dynv6.com/) dynamic DNS setup
  - DSLR-sync script

## [Ansible](https://www.ansible.com/) Role Selection
Just edit the `./hosts` file and the `./pi-setup.yml` file to your needs. Especially edit the `[wifi]` section of the `./hosts` file for the [dynv6](https://dynv6.com/) setup (⇨ comments).

Then run

    ansible-playbook pi-setup.yml

Be aware that the default password for the raspberry is **NOT** changed, so you should also do this via an [ansible](https://www.ansible.com/) role or manually.

### Setup Role `02-setup`
This role sets the raspberrys **locale**, **timezone** and **keyboard** layout. Edit the variables in the `./roles/02-setup/vars/main.yml` file to your needs, the default is a german setup.

### Setup Role `02-setup-wifi`
This role sets the raspberrys WiFi (enterprise and WPA2) and LAN settings do DHCP and connects to the configured WiFi(s). Edit the file `./roles/02-setup-wifi/templates/wpa_supplicant.conf` to your needs (⇨ comments).

Additionally it registers the raspberrys **local** (**!**) IPv4 and **external** IPv6 address to dynv6. The original script was from [corny/**dynv6.sh**](https://gist.github.com/corny/7a07f5ac901844bd20c9). There is also a [script for OS-X](https://gist.github.com/Hornet-C/d018303f4d629789fd468227c8c0bdf7) and [MS-Windows](https://gist.github.com/Hornet-C/bd940bba3802d3c7a05129188222ab46) in my [gists](https://gist.github.com/Hornet-C).

The DNS Entry is updated at boot and every 20 minutes (⇨ `./roles/02-setup-wifi/tasks/main.yml`)

### Picture copy Role `03-canon`
This role sets a udev-rule and systemd service to start the script `./03-canon/files/camera-capture.sh` which will be residing at `/home/pi/camera-capture/camera-capture.sh`.

**Be sure to generate a ssh key with [`ssh-keygen`](https://linux.die.net/man/1/ssh-keygen) and transfer it to your destination computer via [`ssh-copy-id`](https://linux.die.net/man/1/ssh-copy-id).**

As soon as the camera is connected, the script will poll the camera for photo changes and send them via rsync to the destination. If the camera is disconnected, it will stop the sync.

TODO:

* explain usage for other camera vendors
* change camera vendor ID and camera ID to ansible variable

## Camera Synchronisation script
### Prerequisites
You'll need `rsync`, `gphotofs` and `fuse`.

### Usage
Of course you can use the script from  `./03-canon/files/camera-capture.sh` without all the rules on any Linux distribution. Edit all the variables at the beginning to your needs, especially the [rsync](https://linux.die.net/man/1/rsync) options at `RSYNC_OPTIONS` and the camera folder `CAMERA_FOLDER` which should me monitored.

**Be sure to generate a ssh key with [`ssh-keygen`](https://linux.die.net/man/1/ssh-keygen) and transfer it to your destination computer via [`ssh-copy-id`](https://linux.die.net/man/1/ssh-copy-id).**

# TODO ⇨ Improvements
Unfortunately I didn't find a way to get notified if the camera took a new picture **or** deleted one. I just managed [gphoto2](https://github.com/gphoto/gphoto2) to notify me if a new picture has been taken, not deleted.

The mounted fuse [gphotofs](https://github.com/gphoto/gphotofs) wasn't able to update either, so I couldn't use [inotify](https://linux.die.net/man/7/inotify) to start rsync if a file was added or deleted.
