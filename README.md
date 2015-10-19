
# CoolProp Docker images

Welcome to *CoolProp/Dockerfiles* - a repository that provides Docker images preconfigured to build and use the CoolProp fluid property database. 

## Structure of the Repository

Most of the images used to build CoolProp employ Debian's stable branch as their base image. Have a look at the `debian` subdirectory to see how these images are created from the official Debian images for 64bit systems. You can even look into the makefile to discover that the 32bit versions are build from scratch in a chroot environment using the scripts provided by [Dashamir Hoxha](https://github.com/docker-32bit/debian). 