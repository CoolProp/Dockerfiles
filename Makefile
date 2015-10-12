
# This is a Makefile to make Dockerfiles

###########################################################
#  Just a test
###########################################################
.PHONY     : basesystem
basesystem : basesystem/Dockerfile

basesystem/Dockerfile: buildsteps/*.txt
	cpp -o basesystem/Dockerfile basesystem/Dockerfile.in


# Dockerfile: Dockerfile.in *.docker
  # cpp -o Dockerfile Dockerfile.in

# build: Dockerfile
  # docker build -rm -t my/image .