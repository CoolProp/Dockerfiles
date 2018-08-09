
# This is a Makefile to make Dockerfiles

CPP:=cpp -w -P

TAG:=latest

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
	sed 's/coolprop\/[a-zA-Z0-9]*/&32/g' <"$1/Dockerfile.1.tmp" > "$1/Dockerfile.2.tmp"                                 && mv "$1/Dockerfile.2.tmp" "$1/Dockerfile.1.tmp"
	# Set the architecture prefix
	sed 's/linux64/linux32/g' <"$1/Dockerfile.1.tmp" > "$1/Dockerfile.2.tmp"                                            && mv "$1/Dockerfile.2.tmp" "$1/Dockerfile.1.tmp"
	sed 's/64bit/32bit/g' "$1/Dockerfile.1.tmp" > "$1/Dockerfile.2.tmp"                                                 && mv "$1/Dockerfile.2.tmp" "$1/Dockerfile.1.tmp"
	# Fix miniconda and the related buildbot tools
	sed 's/Miniconda3-latest-Linux-x86_64/Miniconda3-latest-Linux-x86/g' <"$1/Dockerfile.1.tmp" > "$1/Dockerfile.2.tmp" && mv "$1/Dockerfile.2.tmp" "$1/Dockerfile.1.tmp"
	sed 's/\ wxpython\ /\ /g' "$1/Dockerfile.1.tmp" > "$1/Dockerfile.2.tmp"                                             && mv "$1/Dockerfile.2.tmp" "$1/Dockerfile.1.tmp"
	# Special changes for the manylinux builder
	sed 's/manylinux1_x86_64/manylinux1_i686/g' <"$1/Dockerfile.1.tmp" > "$1/Dockerfile.2.tmp"                          && mv "$1/Dockerfile.2.tmp" "$1/Dockerfile.1.tmp"
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

.PHONY : $1-clean
$1-clean : 
	rm -rf $1/64bit $1/32bit

endef

$(foreach tdir,$(DIRS),$(eval $(call make-goal,$(tdir))))

.PHONY : all
all    : $(DIRS)

.PHONY : debian-build
debian-build : debian/32bit/Dockerfile debian/64bit/Dockerfile
	cd debian/32bit/ ; docker build -t coolprop/debian32 -f Dockerfile . ; cd ../..
	cd debian/64bit/ ; docker build -t coolprop/debian   -f Dockerfile . ; cd ../..

.PHONY : delete
delete : 
	docker rmi -f $(foreach tdir,$(DIRS),coolprop/$(tdir)) $(foreach tdir,$(DIRS),coolprop/$(tdir)32)

.PHONY : clean
clean : basesystem-clean slavebase-clean slavepython-clean manylinux-clean

.PHONY : build-images
build-images : 
	make debian-build
	$(foreach tdir,$(DIRS),make $(tdir)-build;)

.PHONY : tag-images
tag-images : 
	docker tag coolprop/debian   coolprop/debian:$(TAG)
	docker tag coolprop/debian32 coolprop/debian32:$(TAG)
	$(foreach tdir,$(DIRS),docker tag coolprop/$(tdir)   coolprop/$(tdir):$(TAG);)
	$(foreach tdir,$(DIRS),docker tag coolprop/$(tdir)32 coolprop/$(tdir)32:$(TAG);)

.PHONY : push-images
push-images : 
	docker push coolprop/debian
	docker push coolprop/debian32
	$(foreach tdir,$(DIRS),docker push coolprop/$(tdir);)
	$(foreach tdir,$(DIRS),docker push coolprop/$(tdir)32;)
