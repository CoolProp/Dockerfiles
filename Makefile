
# This is a Makefile to make Dockerfiles

CPP:=cpp -w -P

TAG:=v1.4.2

DIRS := basesystem slavebase slavepython manylinux #slaveopen #slavefull

define make-goal
.PHONY : $1
$1 : $1/64bit/Dockerfile $1/32bit/Dockerfile

$1/64bit/Dockerfile : $1/Dockerfile.in buildsteps/*.txt
	mkdir -p "$1/64bit"
	if [ -f "$1/entrypoint.sh" ]; then cp "$1/entrypoint.sh" "$1/64bit/"; fi
	if [ -f "$1/installer.sh" ];  then cp "$1/installer.sh"  "$1/64bit/"; fi
	$(CPP) -o $$@.tmp.2 $$<                                                  && mv $$@.tmp.2 $$@.tmp.1
	echo "# Do not edit this file manually, it was generated on "`date +%Y-%m-%d\ at\ %H:%M`" from $$<" | cat - $$@.tmp.1 > $$@
	rm -f $$@.tmp.1

$1/32bit/Dockerfile : $1/64bit/Dockerfile
	# Create required files and directories
	mkdir -p "$1/32bit"
	if [ -f "$1/64bit/entrypoint.sh" ]; then cp "$1/64bit/entrypoint.sh" "$1/32bit/"; fi
	if [ -f "$1/64bit/installer.sh" ];  then cp "$1/64bit/installer.sh" "$1/32bit/";  fi
	cp "$1/64bit/Dockerfile" "$1/Dockerfile.1.tmp"	
	# Replace the coolprop docker image name with its 32bit version
	sed 's/coolprop\/[a-zA-Z0-9]*/&32/g' <"$1/Dockerfile.1.tmp" > "$1/Dockerfile.2.tmp"                               && mv "$1/Dockerfile.2.tmp" "$1/Dockerfile.1.tmp"
	# Set the architecture prefix
	sed 's/linux64/linux32/g' <"$1/Dockerfile.1.tmp" > "$1/Dockerfile.2.tmp"                                          && mv "$1/Dockerfile.2.tmp" "$1/Dockerfile.1.tmp"
	sed 's/64bit/32bit/g' "$1/Dockerfile.1.tmp" > "$1/Dockerfile.2.tmp"                                               && mv "$1/Dockerfile.2.tmp" "$1/Dockerfile.1.tmp"
	# Fix miniconda and the related buildbot tools
	sed 's/Miniconda-latest-Linux-x86_64/Miniconda-latest-Linux-x86/g' <"$1/Dockerfile.1.tmp" > "$1/Dockerfile.2.tmp" && mv "$1/Dockerfile.2.tmp" "$1/Dockerfile.1.tmp"
	sed 's/\ wxpython\ /\ /g' "$1/Dockerfile.1.tmp" > "$1/Dockerfile.2.tmp"                                           && mv "$1/Dockerfile.2.tmp" "$1/Dockerfile.1.tmp"
	# Special changes for the manylinux builder
	sed 's/manylinux1_x86_64/manylinux1_i686/g' <"$1/Dockerfile.1.tmp" > "$1/Dockerfile.2.tmp"                        && mv "$1/Dockerfile.2.tmp" "$1/Dockerfile.1.tmp"
	# Finish the procesing	
	cp "$1/Dockerfile.1.tmp" "$1/32bit/Dockerfile"
	rm -f "$1/Dockerfile.1.tmp" "$1/Dockerfile.2.tmp"

.PHONY : $1-build
$1-build : $1-build64 $1-build32

.PHONY : $1-build32
$1-build32 : $1/32bit/Dockerfile
	cd $1/32bit ; docker build -t coolprop/$(1)32 -f Dockerfile . ; cd ..
	
.PHONY : $1-build64
$1-build64 : $1/64bit/Dockerfile
	cd $1/64bit ; docker build -t coolprop/$(1) -f Dockerfile . ; cd ..

endef

$(foreach tdir,$(DIRS),$(eval $(call make-goal,$(tdir))))

.PHONY : all
all    : $(DIRS)

.PHONY : debian
debian : externals/debian32/build-image.sh
	mkdir -p debian/64bit debian/32bit
	cp externals/debian32/build-image.sh debian/
	sed 's/http.debian.net/httpredir.debian.org/g' <debian/build-image.sh > debian/build-image.sh.tmp && mv debian/build-image.sh.tmp debian/build-image.sh
	cp debian/build-image.sh debian/32bit/build-image.sh
	sed 's/32bit/64bit/g'                          <debian/build-image.sh > debian/build-image.sh.tmp && mv debian/build-image.sh.tmp debian/build-image.sh
	sed 's/i386/amd64/g'                           <debian/build-image.sh > debian/build-image.sh.tmp && mv debian/build-image.sh.tmp debian/build-image.sh
	cp debian/build-image.sh debian/64bit/build-image.sh
	chmod +x debian/32bit/build-image.sh debian/64bit/build-image.sh
	cd debian/32bit ; sudo ./build-image.sh stable ; cd ..
	docker tag -f 32bit/debian:stable coolprop/debian32
	cd debian/64bit ; sudo ./build-image.sh stable ; cd ..
	docker tag -f 64bit/debian:stable coolprop/debian
	docker tag -f coolprop/debian   coolprop/debian:$(TAG)
	docker tag -f coolprop/debian32 coolprop/debian32:$(TAG)

.PHONY : push-debian
push-debian : 
	docker login
	docker push coolprop/debian
	docker push coolprop/debian32

.PHONY : delete
delete : 
	docker rmi -f $(foreach tdir,$(DIRS),coolprop/$(tdir)) $(foreach tdir,$(DIRS),coolprop/$(tdir)32)

.PHONY : push-images
push-images : 
	docker login
	$(foreach tdir,$(DIRS),docker push coolprop/$(tdir);) 
	$(foreach tdir,$(DIRS),docker push coolprop/$(tdir)32;) 

.PHONY : full-release
full-release : 
	sudo ls
	make debian
	make manylinux-build
	docker tag -f coolprop/manylinux   coolprop/manylinux:$(TAG)
	docker tag -f coolprop/manylinux32 coolprop/manylinux32:$(TAG)
	make basesystem-build
	docker tag -f coolprop/basesystem   coolprop/basesystem:$(TAG)
	docker tag -f coolprop/basesystem32 coolprop/basesystem32:$(TAG)
	make slavebase-build
	docker tag -f coolprop/slavebase   coolprop/slavebase:$(TAG)
	docker tag -f coolprop/slavebase32 coolprop/slavebase32:$(TAG)
	make slavepython-build
	docker tag -f coolprop/slavepython   coolprop/slavepython:$(TAG)
	docker tag -f coolprop/slavepython32 coolprop/slavepython32:$(TAG)

.PHONY : full-push
full-push : push-debian push-images
