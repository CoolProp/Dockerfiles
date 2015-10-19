
# CoolProp Docker images

Welcome to *CoolProp/Dockerfiles* - a repository that provides Docker images preconfigured to build and use the CoolProp fluid property database. 

## Structure of the Repository

Most of the images used to build CoolProp employ Debian's stable branch as their base image. Have a look at the `debian` subdirectory to see how these images are created from scratch in a chroot environment using the scripts provided by [Dashamir Hoxha](https://github.com/docker-32bit/debian). The binaries are uploaded to the [debian](https://hub.docker.com/r/coolprop/debian/) and the [debian32](https://hub.docker.com/r/coolprop/debian32/) repositories on Docker Hub.

Based on the bare Debian images, the [basesystem](https://hub.docker.com/r/coolprop/basesystem/) and [basesystem32](https://hub.docker.com/r/coolprop/basesystem32/) Dockerfiles get built directly on Docker Hub as soon as new commits are pushed to this Git repository. These images contain the basic infrastructure required to compile CoolProp, which can be summarised to the GCC suite, version control systems and a slim Python installation. 