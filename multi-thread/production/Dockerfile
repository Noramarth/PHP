FROM debian:buster-slim

ENV PHP_VERSION 7.4.9

MAINTAINER noramarth@aom.ro

ENV USER app
ENV GROUP app

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
        libargon2-1 \
        libmemcached11 \
        libxml2
ENV APP_DIR /app
ENV PHP_INI_DIR /etc/php
ENV PHP_DOWNLOAD_DIR /usr/local/src/tarballs
ENV PHP_SOURCE_DIR /usr/local/src/php/source
ENV PHP_COMPILE_DIR /usr/local/src/php/compile
ENV MODULES_DIR /usr/local/src/modules
ENV MODULES_DOWNLOAD_DIR $MODULES_DIR/tarballs
ENV PHP_ARCHIVE_FILE php.tar.xz
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"
ENV PHP_URL="https://www.php.net/get/php-$PHP_VERSION.tar.xz/from/this/mirror"
ENV PHP_COMPILE_DEPS \
    libcurl4-openssl-dev \
    libedit-dev \
    libsodium-dev \
    libssl-dev \
    libxml2-dev \
    zlib1g-dev \
    libonig-dev \
    libxml2-dev \
    libargon2-0-dev \
    libc6-dev \
    libmemcached-dev \
    git \
    unzip
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
    --with-tsrm-pthreads \
    --with-openssl \
    --enable-phar \
    --enable-dom \
    --enable-pdo \
    --with-pdo-mysql \
    --enable-pcntl \
    --enable-posix \
    --enable-sockets \
    --enable-xml \
    --enable-filter \
    --enable-maintainer-zts
RUN set -eux; \
	{ \
		echo 'Package: php*' \
		&& echo 'Pin: release *' \
		&& echo 'Pin-Priority: -1'; \
	} > /etc/apt/preferences.d/no-debian-php; \
	mkdir -p "$PHP_INI_DIR/conf.d" \
	&& mkdir -p $APP_DIR \
	&& groupadd -r $GROUP \
	&& useradd -r -g $GROUP $USER \
	&& mkdir -p /home/$USER \
	&& chown $USER:$GROUP /home/$USER \
	&& chown $USER:$GROUP $APP_DIR \
	&& chmod 777 $APP_DIR
RUN set -eux \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
	    $PHP_RUNTIME_DEPS \
	&& rm -rf /var/lib/apt/lists/*;
RUN set -eux; \
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
	    dirmngr \
	    autoconf \
	    automake \
	    autotools-dev \
	    libtool \
	    build-essential \
	    curl \
        ca-certificates \
        xz-utils \
        $PHP_COMPILE_DEPS \
        $PHPIZE_DEPS; \
	rm -rf /var/lib/apt/lists/*; \
    mkdir -p $PHP_DOWNLOAD_DIR; \
    cd $PHP_DOWNLOAD_DIR; \
    curl -fsSL -o $PHP_ARCHIVE_FILE "$PHP_URL"; \
    export CFLAGS="$PHP_CFLAGS"; \
    export CPPFLAGS="$PHP_CPPFLAGS"; \
    export LDFLAGS="$PHP_LDFLAGS"; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
	if [ ! -d /usr/include/curl ]; then \
		ln -sT "/usr/include/$debMultiarch/curl" /usr/local/include/curl; \
	fi; \
	mkdir -p $PHP_SOURCE_DIR; \
	tar -xf $PHP_DOWNLOAD_DIR/$PHP_ARCHIVE_FILE -C $PHP_SOURCE_DIR --strip-components=1; \
	rm -rf PHP_DOWNLOAD_DIR; \
    mkdir -p $PHP_COMPILE_DIR; \
    cd $PHP_SOURCE_DIR; \
    ./buildconf --force; \
    cd $PHP_COMPILE_DIR; \
    $PHP_SOURCE_DIR/configure \
        --build="$gnuArch" \
        --with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
        $PHP_CONFIG_OPTIONS;  \
    make -j "$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install; \
    find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; \
    make clean; \
    cp -v $PHP_SOURCE_DIR/php.ini-* "$PHP_INI_DIR/"; \
    cd /; \
    rm -rf $PHP_DOWNLOAD_DIR; \
    mkdir -p $MODULES_DOWNLOAD_DIR; \
    cd $MODULES_DOWNLOAD_DIR; \
    git clone -q https://github.com/igbinary/igbinary.git igbinary; \
    git clone -q https://github.com/phpredis/phpredis.git phpredis; \
    git clone -q https://github.com/php-memcached-dev/php-memcached.git memcached; \
    git clone -q https://github.com/mongodb/mongo-php-driver.git mongodb; \
    git clone -q https://github.com/krakjoe/parallel.git parallel; \
    cd $MODULES_DOWNLOAD_DIR/igbinary; \
    phpize; \
    ./configure CFLAGS="-O2 -g" \
        --enable-igbinary; \
    make -j "$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install; \
    cd $MODULES_DOWNLOAD_DIR/phpredis; \
    phpize; \
    ./configure \
        --enable-redis-igbinary; \
    make -j "$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install; \
    cd $MODULES_DOWNLOAD_DIR/memcached; \
    phpize; \
    ./configure CFLAGS="-O2 -g" \
        --enable-memcached \
        --enable-memcached-igbinary; \
    make -j "$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install; \
    cd $MODULES_DOWNLOAD_DIR/mongodb; \
    git submodule update --init; \
    phpize; \
    ./configure \
        CFLAGS="-O2 -g" \
        --enable-shared \
        --enable-mongodb; \
    make -j "$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install; \
    cd $MODULES_DOWNLOAD_DIR/parallel; \
    phpize; \
    ./configure \
        CFLAGS="-O2 -g" \
        --enable-parallel; \
    make -j "$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install; \
    cd / ;\
    rm -rf $PHP_SOURCE_DIR; \
    rm -rf $PHP_COMPILE_DIR; \
    rm -rf $MODULES_DIR; \
    echo "extension = parallel.so" > $PHP_INI_DIR/conf.d/5-parallel.ini; \
    echo "extension = sodium.so" > $PHP_INI_DIR/conf.d/10-sodium.ini; \
    echo "extension = igbinary.so" > $PHP_INI_DIR/conf.d/10-igbinary.ini; \
    echo "extension = redis.so " > $PHP_INI_DIR/conf.d/20-redis.ini; \
    echo "extension = memcached.so " > $PHP_INI_DIR/conf.d/20-memcached.ini; \
    echo "extension = mongodb.so" > $PHP_INI_DIR/conf.d/30-mongodb.ini; \
    curl -fsSL -o composer.phar 'https://getcomposer.org/composer.phar'; \
    mv composer.phar /usr/bin/composer; \
    chmod +x /usr/bin/composer; \
    composer self-update; \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    find /usr/local -type f -executable -exec ldd '{}' ';' \
        | awk '/=>/ { print $(NF-1) }' \
        | sort -u \
        | xargs -r dpkg-query --search \
        | cut -d: -f1 \
        | sort -u \
        | xargs -r apt-mark manual; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /tmp/*; \
    php -v; \
    php -m

#Cleaning ENV Vars we don't need
RUN unset CFLAGS \
    && unset CPPFLAGS \
    && unset LDFLAGS \
    && unset APP_DIR \
    && unset PHPIZE_DEPS \
    && unset PHP_RUNTIME_DEPS \
    && unset PHP_DOWNLOAD_DIR \
    && unset PHP_SOURCE_DIR \
    && unset PHP_COMPILE_DIR \
    && unset MODULES_DIR \
    && unset MODULES_DOWNLOAD_DIR \
    && unset PHP_ARCHIVE_FILE \
    && unset PHP_COMPILE_DEPS \
    && unset PHP_CONFIG_OPTIONS