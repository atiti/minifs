PACKAGES+=" freetype"
hset freetype url "http://download.savannah.gnu.org/releases/freetype/freetype-2.5.0.1.tar.gz"

download-freetype() {
        if [ ! -f freetype-2.5.0.1.tar.gz ]; then
                wget " http://download.savannah.gnu.org/releases/freetype/freetype-2.5.0.1.tar.gz"
        fi
}

configure-freetype() {
        configure-generic
}

deploy-freetype() {
        deploy rsync -av "$STAGING_USR"/lib/libfreetype* "$ROOTFS"/usr/lib/
}
