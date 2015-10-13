
# This is a Makefile to make Dockerfiles

CPP:=cpp -w -P -o
###########################################################
#  Just a test
###########################################################
.PHONY     : basesystem
basesystem : basesystem/Dockerfile

*/Dockerfile: buildsteps/*.txt
	$(CPP) $@ $@.in


# Dockerfile: Dockerfile.in *.docker
  # cpp -o Dockerfile Dockerfile.in

# build: Dockerfile
  # docker build -rm -t my/image .