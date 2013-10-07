PACKAGES+=" libpng"
hset libpng url "ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng16/libpng-1.6.6.tar.gz"

download-libpng() {
        if [ ! -f libpng-1.6.6.tar.gz ]; then
                wget "ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng16/libpng-1.6.6.tar.gz"
        fi
}

configure-libpng() {
        configure-generic
}

deploy-libpng() {
        deploy rsync -av "$STAGING_USR"/lib/libpng* "$ROOTFS"/usr/lib/
}
