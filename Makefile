
# This is a Makefile to make Dockerfiles

CPP:=cpp -w -P

DIRS := basesystem

define make-goal
.PHONY : $1
$1 : $1/64bit/Dockerfile $1/32bit/Dockerfile

$1/64bit/Dockerfile : $1/Dockerfile.in buildsteps/*.txt
	mkdir -p "$1/64bit"
	$(CPP) -o $$@ $$<

$1/32bit/Dockerfile : $1/64bit/Dockerfile
	mkdir -p "$1/32bit"
	sed 's/coolprop\/[a-zA-Z0-9]*/&32/g' <"$1/64bit/Dockerfile" > "$1/Dockerfile.1.tmp"
	sed 's/Miniconda-latest-Linux-x86_64/Miniconda-latest-Linux-x86/g' <"$1/Dockerfile.1.tmp" > "$1/Dockerfile.2.tmp"
	sed 's/64bit/32bit/g' "$1/Dockerfile.2.tmp" > "$1/32bit/Dockerfile"
	rm -f "$1/Dockerfile.1.tmp" "$1/Dockerfile.2.tmp"

.PHONY : $1-build
$1-build : $1
	cd $1/64bit ; docker build -t coolprop/$1 -f Dockerfile . ; cd ..
	cd $1/32bit ; docker build -t coolprop/$(1)32 -f Dockerfile . ; cd ..

endef

$(foreach tdir,$(DIRS),$(eval $(call make-goal,$(tdir))))

.PHONY : debian
debian : debian/Dockerfile.in externals/debian32/build-image.sh
	mkdir -p debian/64bit debian/32bit
	$(CPP) -o debian/64bit/Dockerfile debian/Dockerfile.in
	cd debian/64bit ; docker build -t coolprop/debian -f Dockerfile . ; cd ..
	cd debian/32bit ; sudo ../../externals/debian32/build-image.sh stable ; cd ..
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