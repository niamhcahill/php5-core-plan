pkg_name=php5
pkg_distname=php
pkg_origin=nc-np
pkg_version=5.6.39
pkg_maintainer="Niamh Cahill"
pkg_license=('PHP-3.01')
pkg_upstream_url=http://php.net/
pkg_description="PHP is a popular general-purpose scripting language that is especially suited to web development."
pkg_source=https://php.net/get/${pkg_distname}-${pkg_version}.tar.bz2/from/this/mirror
pkg_filename=${pkg_distname}-${pkg_version}.tar.bz2
pkg_dirname=${pkg_distname}-${pkg_version}
pkg_shasum=b3db2345f50c010b01fe041b4e0f66c5aa28eb325135136f153e18da01583ad5
pkg_deps=(
  core/coreutils
  core/curl
  core/glibc
  core/libxml2
  core/openssl
  core/readline
  core/zlib
  core/autoconf
)
pkg_build_deps=(
  core/bison2
  core/gcc
  core/make
  core/re2c
)
pkg_bin_dirs=(bin sbin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_interpreters=(bin/php)
pkg_svc_user=root
pkg_svc_group=$pkg_svc_user

do_prepare () {
  if [[ ! -r /usr/bin/xml2-config ]]; then
    ln -sv "$(pkg_path_for libxml2)/bin/xml2-config" /usr/bin/xml2-config
  fi
}

do_build() {
  ./configure --prefix="$pkg_prefix" \
    --sysconfdir="${pkg_svc_config_path}/etc" \
    --with-config-file-path="${pkg_svc_config_path}" \
    --enable-pcntl \
    --enable-exif \
    --enable-fpm \
    --enable-mbstring \
    --enable-opcache \
    --with-readline="$(pkg_path_for readline)" \
    --with-curl="$(pkg_path_for curl)" \
    --with-libxml-dir="$(pkg_path_for libxml2)" \
    --with-openssl="$(pkg_path_for openssl)" \
    --with-xmlrpc \
    --with-zlib="$(pkg_path_for zlib)"
  make
}

do_install() {
  make install

  php_path="$pkg_prefix"
  autoconf_path="$(pkg_path_for core/autoconf)"
  php_ext=$php_path/lib/php/extensions/no-debug-non-zts-20131226
  
  export PHP_AUTOCONF=$autoconf_path/bin/autoconf
  export PHP_AUTOHEADER=$autoconf_path/bin/autoheader
  
  if [ ! -f $php_ext/redis.so ]; then
    pecl install redis
  fi

  if [ ! -f $php_ext/lzf.so ]; then
    pecl install lzf
  fi
}

do_check() {
  make test
}
