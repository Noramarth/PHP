FROM debian:buster-slim
ENV PHP_VERSION 7.4.4
MAINTAINER noramarth@aom.ro
ENV USER app
ENV GROUP app
RUN set -eux; \
	{ \
		echo 'Package: php*'; \
		echo 'Pin: release *'; \
		echo 'Pin-Priority: -1'; \
	} > /etc/apt/preferences.d/no-debian-php
ENV PHPIZE_DEPS \
		autoconf \
		dpkg-dev dpkg \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkgconf \
		re2c
ENV PHP_RUNTIME_DEPS \
        libcurl4 \
        libonig5 \
        libedit2 \
        libsodium23 \
        libssl1.1 \
        libxml2 \
        libargon2-1
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
	xz-utils \
	$PHP_RUNTIME_DEPS \
	; \
	rm -rf /var/lib/apt/lists/*;
ENV APP_DIR /app
ENV PHP_INI_DIR /etc/php
ENV PHP_DOWNLOAD_DIR /usr/local/src
ENV PHP_SOURCE_DIR $PHP_DOWNLOAD_DIR/php/source
ENV PHP_COMPILE_DIR $PHP_DOWNLOAD_DIR/php/compile
ENV PHP_ARCHIVE_FILE php.tar.xz
RUN set -eux; \
	mkdir -p "$PHP_INI_DIR/conf.d"; \
    # allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
	mkdir -p $APP_DIR; \
	groupadd -r $GROUP && useradd -r -g $GROUP $USER; \
	mkdir -p /home/$USER; \
	chown $USER:$GROUP /home/$USER; \
	chown $USER:$GROUP $APP_DIR; \
	chmod 777 $APP_DIR
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"
ENV PHP_URL="https://www.php.net/get/php-$PHP_VERSION.tar.xz/from/this/mirror"
RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends dirmngr ; \
	rm -rf /var/lib/apt/lists/*; \
    mkdir -p $PHP_DOWNLOAD_DIR; \
    cd $PHP_DOWNLOAD_DIR; \
    \
    curl -fsSL -o $PHP_ARCHIVE_FILE "$PHP_URL"; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark > /dev/null; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
ENV PHP_COMPILE_DEPS \
    libcurl4-openssl-dev \
    libedit-dev \
    libsodium-dev \
    libssl-dev \
    libxml2-dev \
    zlib1g-dev \
    libonig-dev \
    libargon2-0-dev
ENV PHP_CONFIG_OPTIONS \
    --disable-all \
    --enable-static \
    --enable-option-checking=fatal \
    --enable-cli \
    --enable-ctype \
    --with-iconv \
    --enable-json \
    --with-pcre-jit \
    --enable-session \
    --enable-tokenizer \
    --with-libxml \
    --enable-simplexml \
    --enable-opcache \
    --enable-mysqlnd \
    --with-sodium=shared \
    --with-password-argon2 \
    --with-mhash \
    --enable-mbstring \
    --with-curl \
    --with-libedit \
    --with-zlib \
    --with-openssl \
    --enable-dom \
    --enable-pdo \
    --with-pdo-mysql \
    --enable-xml \
    --enable-filter
RUN export \
		CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS" \
	; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
    # https://bugs.php.net/bug.php?id=74125
	if [ ! -d /usr/include/curl ]; then \
		ln -sT "/usr/include/$debMultiarch/curl" /usr/local/include/curl; \
	fi; \
	mkdir -p $PHP_SOURCE_DIR ; \
	tar -xf $PHP_DOWNLOAD_DIR/$PHP_ARCHIVE_FILE -C $PHP_SOURCE_DIR --strip-components=1 ;\
	set -eux; \
    	\
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    $PHP_COMPILE_DEPS \
    $PHPIZE_DEPS \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p $PHP_COMPILE_DIR; \
    cd $PHP_SOURCE_DIR; \
    ./buildconf --force; \
    cd $PHP_COMPILE_DIR; \
    $PHP_SOURCE_DIR/configure \
        --build="$gnuArch" \
        --with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
        $PHP_CONFIG_OPTIONS ; \
    make -j "$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install ; \
    find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; \
    make clean; \
    cp -v $PHP_SOURCE_DIR/php.ini-* "$PHP_INI_DIR/"; \
    cd / ; \
    rm -rf $PHP_DOWNLOAD_DIR ; \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    find /usr/local -type f -executable -exec ldd '{}' ';' \
        | awk '/=>/ { print $(NF-1) }' \
    	| sort -u \
    	| xargs -r dpkg-query --search \
    	| cut -d: -f1 \
    	| sort -u \
    	| xargs -r apt-mark manual \
    	; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    echo "extension = sodium.so" > $PHP_INI_DIR/conf.d/10-sodium.ini ; \
    php -v; \
    set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        git \
        unzip;
USER app
RUN composer global require hirak/prestissimo
CMD ["php", "-a"]