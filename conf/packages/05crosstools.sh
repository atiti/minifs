
#echo GCC PATH = $GCC
if [ ! -f "$GCC" -o "$COMMAND_PACKAGE" == "crosstools" ]; then 
	PACKAGES+=" crosstools"
	NEED_CROSSTOOLS="crosstools"
	TARGET_PACKAGES+=" crosstools"
fi
hset crosstools url "http://ymorin.is-a-geek.org/download/crosstool-ng/crosstool-ng-$(hget crosstools version).tar.bz2"
hset crosstools depends "linux-headers"

# ${HOME}/x-tools/${CT_TARGET}
# MINIFS_TOOLCHAIN/${CT_TARGET}

reset-crossrools-env() {
	export PATH="$BASE_PATH"
	unset CC CXX GCC LD CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ACLOCAL ; 
	unset PKG_CONFIG_PATH PKG_CONFIG_LIBDIR LD_LIBRARY_PATH ;
}

configure-crosstools() {
	(	# make sure the environment is clean before we start here
		reset-crossrools-env
		# remove "read only" mode
		chmod -R u+w "$TOOLCHAIN"

		# Install missing patches
		for dir in "$PATCHES"/patches/crosstools; do
			if [ -d "$dir"/patches ]; then
				here=$(pwd)
				pushd "$dir"
				tar cf - patches | (cd "$here"; tar xvf -) 
				popd
			fi
		done

		configure ./configure --prefix="$STAGING_TOOLS" &&
			$MAKE &&
			$MAKE install
	)

	mkdir -p "$TOOLCHAIN_BUILD"

	# handles crosstools_menuconfig and so on
	if [ "$COMMAND_PACKAGE" = "crosstools" ] ; then
		set -x
		pushd "$TOOLCHAIN_BUILD"
			rm -f config_crosstools.conf config_uclibc.conf .config
			if [ -f "$CONFIG"/config_crosstools.conf ]; then
				cp "$CONFIG"/config_crosstools.conf \
					"$CONFIG"/config_uclibc.conf .
				cp config_crosstools.conf .config
			fi
			"$STAGING_TOOLS"/bin/ct-ng $COMMAND_TARGET &&
			"$STAGING_TOOLS"/bin/ct-ng show-tuple &&
			cp .config config_crosstools.conf &&
			cp config_crosstools.conf config_uclibc.conf \
				"$CONFIG"/ &&
			rm -f config_crosstools.conf config_uclibc.conf .config
			exit
		popd	
	fi

	(
		reset-crossrools-env
		pushd "$TOOLCHAIN_BUILD"
		rm -f config* .config log.*
		# doctor new config
		for cf in "$CONFIG"/config_crosstools.conf "$CONFIG"/config_uclibc.conf ; do
			dst=$(basename $cf)
			cat $cf | sed \
				-e "s|MINIFS_TOOLCHAIN_BUILD|$TOOLCHAIN_BUILD|g" \
				-e "s|MINIFS_TOOLCHAIN|$TOOLCHAIN|g" \
				-e "s|MINIFS_ROOT|$BASE|g" \
				-e "s|MINIFS_STAGING|$STAGING|g" \
				-e "s|MINIFS_KERNEL|$KERNEL|g" \
				-e "s|MINIFS_CFLAGS|$LIBC_CFLAGS|g" \
				 >"$TOOLCHAIN_BUILD"/$dst
		done

		cp config_crosstools.conf .config

		"$STAGING_TOOLS"/bin/ct-ng show-tuple
		"$STAGING_TOOLS"/bin/ct-ng build$CROSSTOOL_JOBS
	)
}

compile-crosstools() {
	compile echo Done
}

# installing crosstools is just the beginning!
install-crosstools() {
	GCC=$(which $TARGET_FULL_ARCH-gcc)
	if [ ! -f "$GCC" ]; then 
		echo "GCC doesn't exists!! $GCC"
		exit 1
	fi
	log_install echo Done
}

PACKAGES+=" systemlibs"
hset systemlibs url "none"
hset systemlibs dir "."
hset systemlibs depends "crosstools"

configure-systemlibs() {
	configure echo Done
}
compile-systemlibs() {
	compile echo Done
}
install-systemlibs() {
	log_install rsync -a \
		"$CROSS_BASE/$TARGET_FULL_ARCH"/sys-root/lib \
		"$STAGING"/
}


PACKAGES+=" gdbserver"
hset gdbserver url "none"
hset gdbserver dir "."
hset gdbserver phases "deploy"
hset gdbserver depends "busybox"

deploy-gdbserver() {
	local src="$CROSS_BASE/$TARGET_FULL_ARCH"/debug-root/usr/bin/gdbserver
	if [ -f "$src" ]; then
		mkdir -p "$ROOTFS"/usr/bin
		cp "$src" "$ROOTFS"/usr/bin/gdbserver
	fi
}

PACKAGES+=" strace"
hset strace url "http://kent.dl.sourceforge.net/project/strace/strace/4.5.19/strace-4.5.19.tar.bz2"
hset strace depends "busybox"

configure-strace() {
	sed -i -e 's|#undef HAVE_LINUX_NETLINK_H|#define HAVE_LINUX_NETLINK_H 1|' \
		config.h.in
	configure-generic
}

deploy-strace() {
	mkdir -p "$ROOTFS"/usr/bin
	deploy cp "$STAGING_USR"/bin/strace "$ROOTFS"/usr/bin/
}
