PACKAGES+=" airtame"
hset sdldoom url "http://www.libsdl.org/projects/doom/src/sdldoom-1.10.tar.gz"
hset sdldoom depends "libsdl"

download-airtame() {
	if [ ! -f doom1.wad.gz ]; then
		wget "http://www.libsdl.org/projects/doom/data/doom1.wad.gz"
	fi
}

configure-airtame() {
	configure-generic
}

deploy-airtame-local() {
	set -x
	mkdir -p "$ROOTFS"/usr/share/
	gzip -dc "$BASE"/download/doom1.wad.gz \
		>"$ROOTFS"/usr/share/doom1.wad
    cp deploy_binaries
	set +x
}

deploy-airtame() {
	deploy deploy-airtame-local
}
