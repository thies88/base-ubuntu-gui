# Runtime stage
# IMPORTANT NOTE: libgl1-mesa-dri and libllvm10 are removed. In next image use: apt --fix-broken install to re-add 
FROM thies88/base-ubuntu

ARG BUILD_DATE
ARG VERSION
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Thies88"

<<<<<<< HEAD
#Define display vars
#ENV REL=bionic
ENV VNCPASSWD=""
ENV DISPLAY=:99
ENV DISPLAY_WIDTH=1280
ENV DISPLAY_HEIGHT=768
#Color depth 
ENV DEPTH=24
=======
# set version for s6 overlay
#ARG OVERLAY_VERSION="v1.22.0.0"
ARG OVERLAY_VERSION="v2.1.0.2"
ARG OVERLAY_ARCH="amd64"
>>>>>>> 39dde1fbe4b211cbc3a76b3c5e07c658d769bd75

RUN \
 echo "### enable src repos ##" && \
 sed -i "/^#.*deb.*main restricted$/s/^# //g" /etc/apt/sources.list && \
 sed -i "/^#.*deb.*universe$/s/^# //g" /etc/apt/sources.list && \

<<<<<<< HEAD
#echo "Adding nginx repo to fetch latest version of nginx for ${REL}" && \
#echo "deb [arch=amd64] http://nginx.org/packages/mainline/ubuntu/ ${REL} nginx" > /etc/apt/sources.list.d/nginx.list && \
#echo "deb-src http://nginx.org/packages/mainline/ubuntu/ ${REL} nginx" >> /etc/apt/sources.list.d/nginx.list && \

#curl -o /tmp/nginx_signing.key http://nginx.org/keys/nginx_signing.key && \
#apt-key add /tmp/nginx_signing.key && \
#rm -rf /tmp/nginx_signing.key && \
 
 # sed -i "/^#.*deb.*multiverse$/s/^# //g" /etc/apt/sources.list && \
 # fix issue when installing certen build-dep sources
 mkdir /usr/share/man/man1/ && \
 echo "**** install packages for building and running/using noVNC ****" && \
 apt-get update && \
 apt-get install -y --no-install-recommends \
	### For building ###
	git \
	cmake \
	### For running ###
    openbox \
	#obconf \
	python-numpy \
	python3-minimal \
	python-xdg \
	#xterm \
	#openssh-client \
	net-tools \
	nginx \
	xvfb && \
	
# remove temp sourcelist en update source list
rm -rf /etc/apt/sources.list.d/nginx.list && \
#apt update && \

#build xvfb from source (maby for future build):

#apt-get build-dep xvfb
#apt-get source Xvfb
#apt-get install libgl1-mesa-dev
#cd xorg-source*
#./configure --enable-shared=yes
#make install

# install noVNC to usr/share. When starting the container for the first time we move this to: /config/www
cd /usr/share && \
git clone https://github.com/novnc/noVNC && \
rm -rf /usr/share/noVNC/.git* .esl* && \
rm -rf /usr/share/noVNC/.esl* && \
# build and install libvncserver
apt-get build-dep -y libvncserver && \
cd / && \
git clone https://github.com/LibVNC/libvncserver && \
cd /libvncserver && \
cmake . && \
make install && \
#cmake --build .

# build and install x11vnc
apt-get build-dep -y x11vnc && \
cd / && \
git clone https://github.com/LibVNC/x11vnc && \
cd /x11vnc && \
autoreconf -v --install  && \
./configure  && \
make install  && \

# config
#openbox
cp /etc/xdg/openbox/menu.xml /var/lib/openbox/debian-menu.xml && \
#mkdir -p /config/.config/openbox && \
#echo "${APP}" > ~/.config/openbox/autostart && \

# block deb-src* lines in sources.list by adding #
sed -i "/deb-src.*/s/deb-src* /# deb-src /g" /etc/apt/sources.list && \

echo "**** cleanup ****" && \
apt-get autoremove -y --purge \
linux-libc-dev \
nettle-dev \
libssl-dev \
geoip-database \
git \
make cmake cmake-data autoconf automake build-essential patch \
dpkg-dev \
default-jdk-headless default-jre java-common openjdk-11-jre-headless openjdk-11-jdk openjdk-11-jdk-headless \
gcc-7 cpp-7 libgcc-7-dev gcc && \
# removed from autoremove: libgl1-mesa-dri xtrans-dev x11proto-core-dev x11proto-damage-dev x11proto-dev libc6-dev
# unattended-upgrades software-properties-common

# cleaning removed some needed libs. Install libs instead of packages which include these libs to reduce image size.
apt install -y --no-install-recommends \
#	libxtst6 \
	libavahi-client3 \
	python-numpy && \
#	libxdamage1 && \

# remove libgl1-mesa-dri and libllvm10 without deps. xvfb depends on libgl1-mesa-dri but not needed for noVNC to work. Reduces image size with: 108 MB
# restroe with: apt --fix-broken install
# dpkg -r --force-depends libgl1-mesa-dri libglx-mesa0 libllvm10 && \
# backup and edit /var/lib/dpkg/status to stop apt from complaining about unmet dependencies for xvfb.
# cp /var/lib/dpkg/status /var/lib/dpkg/status-backup && \
# sed -i "/, libgl1-mesa-dri*/s/, libgl1-mesa-dri* //g" /etc/apt/sources.list && \

# Clean more temp/junk files
#apt-get autoremove -y --purge && \
apt-get clean && \
=======
# copy sources (replaced with sed: See RUN)
# COPY sources.list /etc/apt/

# temp s6 overlay fix for ubuntu 20.04

# tar xfz \
#        /tmp/s6-overlay.tar.gz -C / --exclude="./bin" && \
# tar xzf \
#        /tmp/s6-overlay.tar.gz -C /usr ./bin && \

# add local files
COPY root/ /

RUN \
 echo "Enable Ubuntu Universe, Multiverse, and deb-src for main. Disable backports" && \
 sed -i 's/^#\s*\(*main restricted\)$/\1/g' /etc/apt/sources.list && \
 sed -i 's/^#\s*\(*universe\)$/\1/g' /etc/apt/sources.list && \
 sed -i 's/^#\s*\(*multiverse\)$/\1/g' /etc/apt/sources.list && \
 sed -i '/-backports/s/^/#/' /etc/apt/sources.list && \
 echo "**** Ripped from Ubuntu Docker Logic ****" && \
 set -xe && \
 echo '#!/bin/sh' \
	> /usr/sbin/policy-rc.d && \
 echo 'exit 101' \
	>> /usr/sbin/policy-rc.d && \
 chmod +x \
	/usr/sbin/policy-rc.d && \
 dpkg-divert --local --rename --add /sbin/initctl && \
 cp -a \
	/usr/sbin/policy-rc.d \
	/sbin/initctl && \
 sed -i \
	's/^exit.*/exit 0/' \
	/sbin/initctl && \
 echo 'force-unsafe-io' \
	> /etc/dpkg/dpkg.cfg.d/docker-apt-speedup && \
 echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' \
	> /etc/apt/apt.conf.d/docker-clean && \
 echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' \
	>> /etc/apt/apt.conf.d/docker-clean && \
 echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' \
	>> /etc/apt/apt.conf.d/docker-clean && \
 echo 'Acquire::Languages "none";' \
	> /etc/apt/apt.conf.d/docker-no-languages && \
 echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' \
	> /etc/apt/apt.conf.d/docker-gzip-indexes && \
 echo 'Apt::AutoRemove::SuggestsImportant "false";' \
	> /etc/apt/apt.conf.d/docker-autoremove-suggests && \
 mkdir -p /run/systemd && \
 echo 'docker' \
	> /run/systemd/container && \
 echo "**** install apt-utils and locales ****" && \
 apt-get update && \
 apt-get install -y \
	apt-utils \
	locales && \
 echo "**** generate locale ****" && \
 locale-gen en_US.UTF-8 && \
 echo "**** install packages ****" && \
 apt-get install -y \
	curl \
	tzdata \
	apt-transport-https \
	gnupg2 && \
 echo "**** add s6 overlay ****" && \
 curl -o \
 /tmp/s6-overlay.tar.gz -L \
	"https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" && \
 tar xfz \
        /tmp/s6-overlay.tar.gz -C / && \
 echo "**** create abc user and make our folders ****" && \
 useradd -u 911 -U -d /config -s /bin/false abc && \
 usermod -G users abc && \
 mkdir -p \
	/app \
	/config \
	/defaults && \
 echo "**** cleanup ****" && \
 #apt-get --purge autoremove -y --allow-remove-essential e2fsprogs && \
 apt-get autoremove && \
 apt-get clean && \
>>>>>>> 39dde1fbe4b211cbc3a76b3c5e07c658d769bd75
 rm -rf \
	/tmp/* \
	/var/cache/apt \
	/var/lib/apt/lists/* \
<<<<<<< HEAD
	/var/cache/apt/* \
	/var/tmp/* \
	/var/log/* \
	/usr/share/doc/* \
	/usr/share/info/* \
	/var/cache/debconf/* \
	/usr/share/zoneinfo/* \
	/usr/share/man/* \
	/usr/share/locale/* \
	# remove stuff
	/libvncserver \
	/x11vnc \
	# clean nginx, we replace tese later on
	/etc/nginx/sites-available/default \
	/etc/nginx/nginx.conf \
	# remove libs
	/usr/lib/x86_64-linux-gnu/libLLVM-10.so.1
	
# add local files
COPY root/ /

ENTRYPOINT ["/bin/bash", "/init"]
=======
	/var/tmp/* \
	/var/log/* \
	/usr/share/locale/* \
	/usr/share/man/* \
        /usr/share/doc/* \
	/usr/share/info \
	/usr/share/zoneinfo/* \
	/var/cache/debconf/*

# Fix some permissions for copied files
#RUN \
# chmod +x /etc/s6/init/init-stage2 && \
# chmod -R 500 /etc/cont-init.d/ && \
# chmod -R 500 /docker-mods

ENTRYPOINT ["/init"]
>>>>>>> 39dde1fbe4b211cbc3a76b3c5e07c658d769bd75
