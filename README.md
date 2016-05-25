
# CoolProp Docker images

Welcome to **CoolProp/Dockerfiles** - a repository that provides Docker images preconfigured to build and use the CoolProp fluid property database. 

## Structure of the Repository

Most of the images used to build CoolProp employ Debian's stable branch as their base image. Have a look at the `debian` subdirectory to see how these images are created from scratch in a chroot environment using the scripts provided by [Dashamir Hoxha](https://github.com/docker-32bit/debian). The binaries are uploaded to the [debian](https://hub.docker.com/r/coolprop/debian/) and the [debian32](https://hub.docker.com/r/coolprop/debian32/) repositories on Docker Hub.

Based on the bare Debian images, the [basesystem](https://hub.docker.com/r/coolprop/basesystem/) and [basesystem32](https://hub.docker.com/r/coolprop/basesystem32/) containers get built directly on Docker Hub as soon as new commits are pushed to this Git repository. These images contain the basic infrastructure required to compile CoolProp, which can be summarised to the GCC suite, version control systems and a slim Python installation. 

Note that the largest images `coolprop/slaveopen` and `coolprop/slaveopen32` are not part of the automatic build system. They have to be generated and uploaded manually and you have to accept a certain delay, but you can always build your own images from the Dockerfiles provided here. As of November 2015, the images are tested with the wrappers for Octave, C#, Java, JavScript

so far untested are: Scilab, Julia

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

The prerequisites to build the open-source wrappers are all combined in the `coolprop/slaveopen` image. The `slavefull` 
folder contains files and instructions to build an image including the proprietary software like MATLAB and alike. These images have 
to be built *locally* since the contain software that requires specific licenses. You can also install the software *after* the image 
has been launched for the first time using the `docker exec -it` commands.

## Release Cycles

The preferred release process is as follows:

 - remove all old images: `make delete` (or ``docker stop `docker ps -aq`; docker rm `docker ps -aq`; docker rmi `docker images -q`;``)
 - put a real version number in `buildsteps/base.txt` and in `Makefile`
 - `make full-release`
 - `make full-push`
 - commit the changes, tag the files in git and push to remote
 - enter the dummy version number (latest) in `buildsteps/base.txt` and in `Makefile`
 - `make all`
 - commit the changes to git master and push

If you build one image at a time, you should respect the internal dependecies and make the 
targets in the same order as  `make full-release` does. Remember to tag the new images 
before you build the next one. 

Another possibility is to use the automated build service. Also here you have to start with 
the debian images and the rest should just work. Wait between each push to allow 
the automatic builds to catch up with the new images. In a nutshell, the following commands 
should work for a release: 

```Bash
TAG=v1.4.2
make debian push-debian
make all
git commit manylinux/32bit/Dockerfile manylinux/64bit/Dockerfile -m "Updated manylinux for ${TAG}" 
# Continue directly, the manylinux image has no internal dependencies
git commit basesystem/32bit/Dockerfile basesystem/64bit/Dockerfile -m "Updated basesystem for ${TAG}" && git push
# Wait for https://hub.docker.com/r/coolprop/basesystem/builds/ and https://hub.docker.com/r/coolprop/basesystem32/builds/ 
git commit slavebase/32bit/Dockerfile slavebase/64bit/Dockerfile -m "Updated slavebase for ${TAG}" && git push
# Wait for https://hub.docker.com/r/coolprop/slavebase/builds/ and https://hub.docker.com/r/coolprop/slavebase32/builds/ 
git commit slavepython/32bit/Dockerfile slavepython/64bit/Dockerfile -m "Updated slavepython for ${TAG}" && git push
# Wait for https://hub.docker.com/r/coolprop/slavepython/builds/ and https://hub.docker.com/r/coolprop/slavepython32/builds/ 
```

Enter the dummy version numbers in `buildsteps/base.txt` (latest) and in the `Makefile` (latest) and rerun `make all` and commit 
the new files.



## DNS problems

If you run into DNS issues like `Could not resolve 'httpredir.debian.org'`, [here](https://norasky.wordpress.com/2015/06/09/docker-build-could-not-resolve/), 
you can uncomment the line `DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"` in `/etc/default/docker`. If you still have problems after that, you might want to 
add your local nameserver to the configuration file and do not forget to restart docker with `sudo /etc/init.d/docker restart`.

## Additional Information

You can find more information in the developer section of the [CoolProp homepage](http://coolprop.sourceforge.net/develop/index.html). The Dockerfiles in this repository should be self-explanatory. Please note the files are generated by a makefile and should not be edited manually.

