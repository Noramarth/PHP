FROM debian:buster-slim

ENV PHP_VERSION 8.1.4

MAINTAINER radu.dragomir@sde.center

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
		cmake \
		re2c
ENV PHP_RUNTIME_DEPS \
        gnupg \
        openssl \
        apt-transport-https \
        ca-certificates \
        libcurl4 \
        libonig5 \
        libedit2 \
        libsodium23 \
        libssl1.1 \
        libargon2-1 \
        libyaml-0-2 \
        git \
        curl \
        unzip \
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
    libssl-dev \
    libedit-dev \
    libargon2-dev \
    libsodium-dev \
    libxml2-dev \
    zlib1g-dev \
    libonig-dev \
    libxml2-dev \
    libc6-dev \
    libyaml-dev \
    libpng-dev \
    libwebp-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libgmp-dev \
    libzip-dev \
    libxpm-dev \
    unzip \
    libpq-dev \
    unixodbc-dev

ENV PHP_CONFIG_OPTIONS \
    --disable-all \
    --enable-option-checking=fatal \
    --enable-cli \
    --enable-ctype \
    --enable-dom \
    --enable-fileinfo \
    --enable-filter \
    --enable-zts \
    --enable-fpm \
    --enable-mbstring \
    --enable-mysqlnd \
    --enable-opcache \
    --enable-opcache-jit \
    --enable-pcntl \
    --enable-phar \
    --enable-pdo \
    --enable-posix \
    --enable-simplexml \
    --enable-sockets \
    --enable-static \
    --enable-tokenizer \
    --enable-xml \
    --with-curl \
    --with-iconv \
    --with-libedit \
    --with-libxml \
    --with-mhash \
    --with-openssl \
    --with-password-argon2 \
    --with-pcre-jit \
    --with-pdo-mysql \
    --with-sodium=shared \
    --with-pgsql \
    --with-pdo-pgsql \
    --with-zlib \
    --with-zip
ENV MSSQL_RUNTIME_DEPS \
        libodbc1 \
        odbcinst1debian2 \
        unixodbc \
        msodbcsql17 \
        mssql-tools \
        libgssapi-krb5-2

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

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
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - ;\
    curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list ;\
    apt-get update ;\
        ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
            $MSSQL_RUNTIME_DEPS; \
    rm -rf /var/lib/apt/lists/*; \
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
    git clone -q https://github.com/krakjoe/apcu.git apcu; \
    git clone -q https://github.com/php/pecl-file_formats-yaml.git yaml; \
    git clone -q -b v5.9.0 https://github.com/microsoft/msphpsql.git sqlserver; \
    git clone -q --depth=1 -b v1.36.2 https://github.com/grpc/grpc grpc; \
    cd $MODULES_DOWNLOAD_DIR/grpc; \
        git submodule update --init; \
        mkdir -p cmake/build ;\
        pushd "cmake/build" ; \
        cmake ../..  \
          -DBUILD_SHARED_LIBS=ON \
          -DgRPC_INSTALL=ON \
          -DCMAKE_BUILD_TYPE=Release; \
        find -type f -name '*.a' -delete; \
        make install; \
        popd; \
        cd src/php/ext/grpc; \
        phpize; \
        ./configure; \
        make -j "$(nproc)"; \
        find -type f -name '*.a' -delete; \
        make install;\
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
    cd $MODULES_DOWNLOAD_DIR/sqlserver/source; \
    cp -r shared sqlsrv/shared; \
    cp -r shared pdo_sqlsrv/shared; \
    cd sqlsrv; \
    phpize; \
    ./configure \
        --enable-sqlsrv=shared; \
    make -j "$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install; \
    cd ../pdo_sqlsrv; \
    phpize; \
    ./configure \
        --enable-pdo \
        --with-pdo-sqlsrv=shared; \
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
    echo "extension = redis.so " > $PHP_INI_DIR/conf.d/20-redis.ini; \
    echo "extension = grpc.so" > $PHP_INI_DIR/conf.d/20-grpc.ini; \
    echo "extension=sqlsrv.so" > $PHP_INI_DIR/conf.d/20-sqlserver.ini; \
    echo "extension=pdo_sqlsrv.so" > $PHP_INI_DIR/conf.d/30-pdo_sqlsrv.ini; \
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
    && unset PHPIZE_DEPS \
    && unset PHP_RUNTIME_DEPS \
    && unset PHP_DOWNLOAD_DIR \
    && unset PHP_SOURCE_DIR \
    && unset PHP_COMPILE_DIR \
    && unset MODULES_DIR \
    && unset MODULES_DOWNLOAD_DIR \
    && unset PHP_ARCHIVE_FILE \
    && unset PHP_COMPILE_DEPS \
    && unset PHP_CONFIG_OPTIONS \
    && unset MSSQL_RUNTIME_DEPS

COPY --from=composer:2.0 /usr/bin/composer /usr/local/bin/composer

COPY ../base/config/php.ini /usr/local/etc/php/php.ini

RUN mkdir -p $APP_DIR/var/log/php \
    && mkdir -p $APP_DIR/var/cache/ \
    && chown -R $USER:$GROUP $APP_DIR \
    && chmod -R +x $APP_DIR;

STOPSIGNAL SIGQUIT

WORKDIR $APP_DIR

CMD php-fpm