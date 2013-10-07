PACKAGES+=" rpifirmware"
hset rpifirmware url "git!https://github.com/raspberrypi/firmware.git#rpifirmware.tar.bz2"
hset rpifirmware depends "linux-modules"

download-airtame() {
        if [ ! -d "firmware" ]; then
		echo "hi";
	fi
}

configure-rpifirmware() {
	CPWD=`pwd`
	cd opt/vc/src/hello_pi/;
	ls -la
	SDKSTAGE=$CPWD ./rebuild.sh
	cd ../../../../;
	rsync -a opt "$STAGING_USR"
}

deploy-rpifirmware() {
	mkdir -p "$ROOTFS"/opt
	deploy rsync -a "$STAGING_USR"/opt/ "$ROOTFS"/opt/
}
