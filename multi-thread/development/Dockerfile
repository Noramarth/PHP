FROM debian:buster-slim

ENV PHP_VERSION 8.0.2

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
        curl \
        git \
        ca-certificates \
        libcurl4 \
        libonig5 \
        libedit2 \
        libsodium23 \
        libssl1.1 \
        libargon2-1 \
        libyaml-0-2 \
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
    libyaml-dev \
    libpng-dev \
    libwebp-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libgmp-dev \
    libzip-dev \
    unzip
ENV PHP_CONFIG_OPTIONS \
    --disable-all \
    --enable-option-checking=fatal \
    --enable-cli \
    --enable-ctype \
    --enable-dom \
    --enable-fileinfo \
    --enable-ftp \
    --enable-gd \
    --enable-intl \
    --enable-filter \
    --enable-mbstring \
    --enable-mysqlnd \
    --enable-opcache \
    --enable-opcache-jit \
    --enable-pcntl \
    --enable-phar \
    --enable-pdo \
    --enable-posix \
    --enable-simplexml \
    --enable-sysvmsg \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-sockets \
    --enable-static \
    --enable-tokenizer \
    --enable-zts \
    --enable-xml \
    --enable-xmlreader \
    --with-curl \
    --with-freetype \
    --with-gmp \
    --with-iconv \
    --with-jpeg \
    --with-libedit \
    --with-libxml \
    --with-mhash \
    --with-openssl \
    --with-password-argon2 \
    --with-pcre-jit \
    --with-pdo-mysql \
    --with-sodium=shared \
    --with-zip \
    --with-zlib \
    --with-webp

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
    git clone -q https://github.com/krakjoe/apcu.git apcu; \
    git clone -q https://github.com/krakjoe/parallel.git \
    git clone -q https://github.com/php/pecl-file_formats-yaml.git yaml; \

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
        --enable-redis \
        --enable-redis-igbinary \
        --disable-redis-session; \
    make -j "$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install; \
    cd $MODULES_DOWNLOAD_DIR/apcu; \
    phpize; \
    ./configure; \
    make -j "$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install; \
    cd $MODULES_DOWNLOAD_DIR/yaml; \
    phpize; \
    ./configure \
        --with-yaml ;\
    make -j "$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install; \
    cd $MODULES_DOWNLOAD_DIR/parallel; \
        phpize; \
        ./configure \
            --enable-parallel ;\
        make -j "$(nproc)"; \
        find -type f -name '*.a' -delete; \
        make install; \
    cd / ;\
    rm -rf $PHP_SOURCE_DIR; \
    rm -rf $PHP_COMPILE_DIR; \
    rm -rf $MODULES_DIR; \
    echo "extension = apcu.so " > $PHP_INI_DIR/conf.d/10-apcu.ini; \
    echo "extension = yaml.so " > $PHP_INI_DIR/conf.d/10-yaml.ini; \
    echo "extension = sodium.so" > $PHP_INI_DIR/conf.d/10-sodium.ini; \
    echo "extension = igbinary.so" > $PHP_INI_DIR/conf.d/10-igbinary.ini; \
    echo "zend_extension = opcache.so" > $PHP_INI_DIR/conf.d/10-jit.ini; \
    echo "opcache.enable=1" >> $PHP_INI_DIR/conf.d/10-jit.ini; \
    echo "opcache.enable_cli=1" >> $PHP_INI_DIR/conf.d/10-jit.ini; \
    echo "opcache.jit_buffer_size=100M" >> $PHP_INI_DIR/conf.d/10-jit.ini; \
    echo "opcache.jit=1255" >> $PHP_INI_DIR/conf.d/10-jit.ini; \
    echo "extension = parallel.so " > $PHP_INI_DIR/conf.d/10-parallel.ini; \
    echo "extension = redis.so " > $PHP_INI_DIR/conf.d/20-redis.ini; \
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
    rm -rf /tmp/*;
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

RUN mkdir -p /app/var/log/php \
    && mkdir -p /app/var/cache/ \
    && chown -R app:app /app \
    && chmod -R +x /app ;

COPY config/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY config/php.ini /etc/php/php.ini
COPY config/pool.conf /etc/php/pools/pool.conf

COPY entrypoint/entrypoint.sh /opt/entrypoint.sh

RUN chmod +x /opt/entrypoint.sh

COPY --from=composer:2.0 /usr/bin/composer /usr/local/bin/composer

STOPSIGNAL SIGQUIT

WORKDIR /app

ENTRYPOINT /opt/entrypoint.sh

USER app