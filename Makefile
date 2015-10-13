
# This is a Makefile to make Dockerfiles

CPP:=cpp -w -P
###########################################################
#  Just a test
###########################################################
.PHONY     : basesystem
basesystem : basesystem/Dockerfile

basesystem/Dockerfile: buildsteps/*.txt
	$(CPP) -o $@ $@.in


# Dockerfile: Dockerfile.in *.docker
  # cpp -o Dockerfile Dockerfile.in

# build: Dockerfile
  # docker build -rm -t my/image .