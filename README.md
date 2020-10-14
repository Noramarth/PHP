# PHP Custom images

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) 

Package details (latest)

PHP_VERSION 7.4.9,  
PROTOBUFF_VERSION 3.12.3 (for grpc images)  
GRPC_VERSION 1.29.1  

All *`dev`* versions includes: `git`, `composer` latest version at the time of the build
GRPC *`dev`* version contains the `protoc` and `grpc`_php_plugin binaries 

Available PHP modules:

&nbsp;&nbsp;&nbsp;&nbsp;`memcached` and `redis` have `igbinary` capabilities,  
&nbsp;&nbsp;&nbsp;&nbsp;`libsodium` is compiled with `argon2` support

CLI version: 

`Core`, 
`ctype`,
`curl`, 
`date`, 
`dom`, 
`filter`, 
`hash`, 
`iconv`, 
`igbinary`, 
`json`, 
`libxml`, 
`mbstring`, 
`memcached`,
`mongodb`, 
`mysqlnd`, 
`openssl`, 
`pcntl`, 
`pcre`, 
`PDO`, 
`pdo_mysql`, 
`Phar`, 
`posix`, 
`readline`, 
`redis`, 
`Reflection`,
`SimpleXML`, 
`sockets`, 
`sodium`,
`SPL`, 
`standard`, 
`tokenizer`, 
`xml`, 
`zlib`

GRPC version: 

`Core`, 
`ctype`,
`curl`, 
`date`, 
`dom`, 
`filter`, 
`hash`, 
`iconv`, 
`igbinary`, 
`json`, 
`libxml`, 
`mbstring`, 
`memcached`,
`mongodb`, 
`mysqlnd`, 
`openssl`, 
`pcntl`, 
`pcre`, 
`PDO`, 
`pdo_mysql`, 
`Phar`, 
`posix`, 
`readline`, 
`redis`, 
`Reflection`,
`SimpleXML`, 
`sockets`, 
`sodium`,
`SPL`, 
`standard`, 
`tokenizer`, 
`xml`, 
`zlib`

FPM version: 

`Core`, 
`ctype`,
`curl`, 
`date`, 
`dom`, 
`filter`, 
`hash`, 
`iconv`, 
`igbinary`, 
`json`, 
`libxml`, 
`mbstring`, 
`memcached`,
`mongodb`, 
`mysqlnd`, 
`openssl`, 
`pcre`, 
`PDO`, 
`pdo_mysql`, 
`Phar`, 
`readline`, 
`redis`, 
`Reflection`, 
`session`, 
`SimpleXML`, 
`sockets`, 
`sodium`,
`SPL`, 
`standard`, 
`tokenizer`, 
`xml`, 
`zlib`


## NOTE:  
These are custom builds! in case you want to add to them here's info you need to extend them:
- Images for the CLI, Multi-Thread and GRPC versions **DO NOT** have CMD lines as they should be customized anywway according to your needs.  
- PHP INI files are in /etc/php.
- Always compile your modules, do not use pecl:  

code additions to make your life easier in case you want to add modules:  
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
