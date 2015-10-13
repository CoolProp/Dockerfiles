
# This is a Makefile to make Dockerfiles

CPP:=cpp -w -P

DIRS := basesystem

define make-goal
.PHONY : $1
$1 : $1/Dockerfile $1/Dockerfile32

$1/Dockerfile : $1/Dockerfile.in buildsteps/*.txt
	$(CPP) -o $$@ $$@.in

$1/Dockerfile32 : $1/Dockerfile
	sed 's/coolprop\/debian/coolprop\/debian32/g' $1/Dockerfile > $1/Dockerfile32.tmp
	sed 's/Miniconda-latest-Linux-x86_64/Miniconda-latest-Linux-x86/g' $1/Dockerfile32.tmp > $1/Dockerfile32
	rm -f $1/Dockerfile32.tmp

.PHONY : $1-build
$1-build : $1
	cd $1 ; docker build -t coolprop/$1 -f Dockerfile . ; cd ..
	cd $1 ; docker build -t coolprop/$(1)32 -f Dockerfile32 . ; cd ..

endef

$(foreach tdir,$(DIRS),$(eval $(call make-goal,$(tdir))))

.PHONY : debian
debian : debian/Dockerfile.in externals/debian32/build-image.sh
	$(CPP) -o debian/Dockerfile debian/Dockerfile.in
	cd debian ; docker build -t coolprop/debian -f Dockerfile . ; cd ..
	cd debian ; sudo ../externals/debian32/build-image.sh stable ; cd ..
	docker tag -f 32bit/debian:stable coolprop/debian32

.PHONY : push
push : debian
	docker login
	docker push coolprop/debian
	docker push coolprop/debian32


.PHONY : 32bit
32bit : $(DIRS)
	sudo ./externals/debian32/build-image.sh
	docker tag 32bit/debian:jessie coolprop/basesystem32




###########################################################
#  Just a test
###########################################################
#.PHONY     : basesystem
#basesystem : basesystem/Dockerfile

#basesystem/Dockerfile: buildsteps/*.txt
#	$(CPP) -o $@ $@.in




# Dockerfile: Dockerfile.in *.docker
  # cpp -o Dockerfile Dockerfile.in

# build: Dockerfile
  # docker build -rm -t my/image .