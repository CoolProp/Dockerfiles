
# CoolProp Docker images

Welcome to *CoolProp/Dockerfiles* - a repository that provides Docker images preconfigured to build and use the CoolProp fluid property database. 

## Structure of the Repository

Most of the images used to build CoolProp employ Debian's stable branch as their base image. Have a look at the `debian` subdirectory to see how these images are created from scratch in a chroot environment using the scripts provided by [Dashamir Hoxha](https://github.com/docker-32bit/debian). The binaries are uploaded to the [debian](https://hub.docker.com/r/coolprop/debian/) and the [debian32](https://hub.docker.com/r/coolprop/debian32/) repositories on Docker Hub.

Based on the bare Debian images, the [basesystem](https://hub.docker.com/r/coolprop/basesystem/) and [basesystem32](https://hub.docker.com/r/coolprop/basesystem32/) Dockerfiles get built directly on Docker Hub as soon as new commits are pushed to this Git repository. These images contain the basic infrastructure required to compile CoolProp, which can be summarised to the GCC suite, version control systems and a slim Python installation. 

## Size Restrictions

If you run into disk space problems in a virtual docker machine (Windows or OSX), you can use

```
docker-machine stop default
cd .docker/machine/machines/default/
VBoxManage clonehd disk.vmdk disk-temp.vdi --format vdi
VBoxManage modifymedium disk disk-temp.vdi --resize 51200 # 1024MB/GB*50GB
VBoxManage clonehd disk-temp.vdi disk-resized.vmdk --format vmdk
mv disk.vmdk disk.vmdk.old
mv disk-resized.vmdk disk.vmdk
docker-machine start default
```

if all went well, you can remove the old disks with `rm disk.vmdk.old disk-temp.vdi`. You might have 
to add the VirtualBox folder to your path. On Windows, this is typically `C:\Program Files\Oracle\VirtualBox` 
and you add it by running `set PATH=%PATH%;C:\Program Files\Oracle\VirtualBox`.

## Installing Proprietary Software

The prerequisites to build the open-source wrappers are all combined in the `coolprop/slavelinuxopen` image. The `slavelinuxopen` 
folder contains files and instructions to build an image including the proprietary software like MATLAB and alike. These images have 
to be built *locally* since the contain sofyware that requires specific licenses. 

## Additional Information

You can find more information in the developer section of the [CoolProp homepage](http://coolprop.sourceforge.net/develop/index.html). The Dockerfiles in this repository should be self-explanatory. Please note the files are generated by a makefile and should not be edited manually.

