# PHP Custom images

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) 

Package details (latest)

PHP_VERSION 8.0.2,  
PROTOBUFF_VERSION 3.12.3 (for grpc images)  
GRPC_VERSION 1.29.1  

All *`dev`* versions includes: `git`, `composer` latest version at the time of the build
Available PHP modules:

&nbsp;&nbsp;&nbsp;&nbsp; `redis` has `igbinary` capabilities,  
&nbsp;&nbsp;&nbsp;&nbsp; `libsodium` is compiled with `argon2` support


CLI & FPM version: 

`Core`,
`ctype`,
`dom`,
`fileinfo`,
`ftp`,
`gd` (with `jpeg`, `zlib` and `webp` support -- **`png` is included by default since php 8.0**),
`intl`,
`filter`,
`mbstring`,
`mysqlnd`,
`opcache`,
`opcache-jit`,
`pcntl`,
`phar`,
`pdo`,
`posix`,
`session`,
`simplexml`,
`sysvmsg`,
`sysvsem`,
`sysvshm`,
`sockets`,
`tokenizer`,
`xml`,
`xmlreader`,
`curl`,
`freetype`,
`gmp`,
`iconv`,
`libedit`,
`libxml`,
`mhash`,
`openssl`,
`password-argon2`,
`pcre-jit`,
`pdo-mysql`,
`sodium` (shared),
`zip`,

GRPC version:

`Core`,
`ctype`,
`dom`,
`fileinfo`,
`ftp`,
`gd` (with `jpeg`, `zlib` and `webp` support  -- **`png` is included by default since php 8.0**),
`intl`,
`filter`,
`mbstring`,
`mysqlnd`,
`opcache`,
`opcache-jit`,
`pcntl`,
`phar`,
`pdo`,
`posix`,
`simplexml`,
`sysvmsg`,
`sysvsem`,
`sysvshm`,
`sockets`,
`tokenizer`,
`xml`,
`xmlreader`,
`curl`,
`freetype`,
`gmp`,
`iconv`,
`libedit`,
`libxml`,
`mhash`,
`openssl`,
`password-argon2`,
`pcre-jit`,
`pdo-mysql`,
`sodium` (shared),
`zip`,
`zts`

ZTS (Multithread version):

`Core`,
`ctype`,
`dom`,
`fileinfo`,
`ftp`,
`gd` (with `jpeg`, `zlib` and `webp` support  -- **`png` is included by default since php 8.0**),
`intl`,
`filter`,
`mbstring`,
`mysqlnd`,
`opcache`,
`opcache-jit`,
`pcntl`,
`phar`,
`pdo`,
`posix`,
`simplexml`,
`sysvmsg`,
`sysvsem`,
`sysvshm`,
`sockets`,
`tokenizer`,
`xml`,
`xmlreader`,
`curl`,
`freetype`,
`gmp`,
`iconv`,
`libedit`,
`libxml`,
`mhash`,
`openssl`,
`password-argon2`,
`pcre-jit`,
`pdo-mysql`,
`sodium` (shared),
`zip`,
`zts`,
`parallel`

###New addition: 
Protobuf compiler image

In order to use it:

####Examples:

######For PHP Classes generation:
```shell
buffers=$(find . -name '*.proto' -type f -printf "/<path to proto files>/%P ");
docker run -it -v "$BUFFERS_DIRECTORY":/opt/proto -v "$PHP_CLASSES_DIRECTORY":/opt/php_out aomgroup/proto-builder protoc --php_out=/opt/php_out --php-grpc_out=/opt/php_out --proto_path=/opt/proto $buffers;
```

######For JS Classes generation:
```shell
buffers=$(find . -name '*.proto' -type f -printf "/<path to proto files>/%P ");
docker run -it -v "$BUFFERS_DIRECTORY":/opt/proto -v "$JS_CLASSES_DIRECTORY":/opt/js_out aomgroup/proto-builder protoc  -I=/opt/proto $buffers --js_out=import_style=commonjs:/opt/js_out --grpc-web_out=import_style=commonjs,mode=grpcwebtext:/opt/js_out;
```

## NOTE:  
These are custom builds! in case you want to add to them here's info you need to extend them:
- Images for the CLI, Multi-Thread and GRPC versions **DO NOT** have CMD lines as they should be customized anywway according to your needs.  
- PHP INI files are in /etc/php.
- Always compile your modules, do not use pecl:  

app additions to make your life easier in case you want to add modules:  
```
FROM <base image>

ENV TARGET_DIRECTORY <target directory> #I prefer to set this to /usr/local/src but you can put it anywhere
ENV SOURCE_DIRECTORY $TARGET_DIRECTORY/src 
ENV COMPILE_DIRECTORY $TARGET_DIRECTORY/compile

RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ... #add any compile dependencies here \ 
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p $SOURCE_DIRECTORY; 
    mkdir -p $COMILE_DIRECTORY; 
    git clone -q --branch <tag/version> https://github.com/<module-repository>/<module-name> $SOURCE_DIRECORY 
    cd $SOURCE_DIRECTORY;
    phpize;
    cd $COMPILE_DIRECTOR; 
    $SOURCE_DIRECTORY/configure CFLAGS="-O2 -g" \ 
        ... #add any other configure option you may need here \ 
    ; 
    make -j "$(nproc)"; \ 
    find -type f -name '*.a' -delete; \ 
    make install; \
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
    rm -rf $TARGET_DIRECTORY;\
    echo "<zend_>extension = <extension>.so" > $PHP_INI_DIR/conf.d/50-<extension>.ini; \
RUN unset TARGET_DIRECTORY; \
    unset SOURCE_DIRECTORY; \
    unset COMPILE_DIRECTORY;
```
