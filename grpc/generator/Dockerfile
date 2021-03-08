FROM debian:buster-slim

MAINTAINER noramarth@aom.ro

# Switching from sh to bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

#Setting up compile time dependencies
ENV COMPILE_DEPS \
		autoconf \
		dpkg-dev dpkg \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkgconf \
		automake \
		libtool \
		unzip \
		curl \
		autotools-dev \
		ca-certificates \
        xz-utils \
        libtool \
        build-essential \
        dirmngr \
        zlib1g-dev \
        libssl-dev \
        cmake \
        git

#Compiling
RUN set -eux; \
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
        $COMPILE_DEPS; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /usr/local/src; \
    cd /usr/local/src; \
    git clone -b v1.34.0 https://github.com/grpc/grpc; \
    cd grpc ; \
    git submodule update --init --recursive; \
    #install ABSEIL
    mkdir -p "third_party/abseil-cpp/cmake/build"; \
    pushd "third_party/abseil-cpp/cmake/build"; \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE ../..; \
    make -j4 install; \
    popd; \
    # Install c-ares
    mkdir -p "third_party/cares/cares/cmake/build"; \
    pushd "third_party/cares/cares/cmake/build"; \
    cmake -DCMAKE_BUILD_TYPE=Release ../.. ; \
    make -j4 install; \
    popd; \
    # Install protobuf
    mkdir -p "third_party/protobuf/cmake/build"; \
    pushd "third_party/protobuf/cmake/build"; \
    cmake -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release .. ;\
    make -j4 install; \
    popd; \
    # Install re2
    mkdir -p "third_party/re2/cmake/build" ; \
    pushd "third_party/re2/cmake/build"; \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE ../.. ;\
    make -j4 install; \
    popd; \
    # Install GRPC and general plugins
    mkdir -p cmake/build ;\
    pushd "cmake/build" ;\
    cmake ../.. \
      -DgRPC_INSTALL=ON                \
      -DCMAKE_BUILD_TYPE=Release       \
      -DgRPC_ABSL_PROVIDER=package     \
      -DgRPC_CARES_PROVIDER=package    \
      -DgRPC_PROTOBUF_PROVIDER=package \
      -DgRPC_RE2_PROVIDER=package      \
      -DgRPC_SSL_PROVIDER=package      \
      -DgRPC_ZLIB_PROVIDER=package;\
    make -j4 install ;\
    make -j4 plugins ;\
    make install; \
    ldconfig; \
    popd; \
    cd /usr/local/src; \
    mkdir -p protobuf/plugins; \
    pushd "protobuf/plugins"; \
    curl -L https://github.com/spiral/php-grpc/releases/download/v1.4.1/protoc-gen-php-grpc-1.4.1-linux-amd64.tar.gz --output protoc-gen-php-grpc.targ.gz ; \
    tar -xzf protoc-gen-php-grpc.targ.gz; \
    mv protoc-gen-php-grpc-1.4.1-linux-amd64/protoc-gen-php-grpc /usr/local/bin/protoc-gen-php-grpc; \
    curl -L https://github.com/grpc/grpc-web/releases/download/1.2.1/protoc-gen-grpc-web-1.2.1-linux-x86_64 --output /usr/local/bin/protoc-gen-grpc-web; \
    chmod +x /usr/local/bin/protoc-gen-grpc-web; \
    popd; \
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
    rm -rf /usr/local/src/*; \
    mkdir -p /opt/php_out; \
    mkdir -p /opt/js_out;

RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            lsb-core \
            software-properties-common \
            gnupg \
            apt-transport-https \
            ca-certificates \
            curl; \
    apt-mark auto '.*' > /dev/null; \
    add-apt-repository -y -r ppa:chris-lea/node.js \
    && rm -f /etc/apt/sources.list.d/chris-lea-node_js-*.list \
    && rm -f /etc/apt/sources.list.d/chris-lea-node_js-*.list.save \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - ;\
    DISTRO="$(lsb_release -s -c)"; \
    VERSION=node_14.x; \
    echo "deb https://deb.nodesource.com/$VERSION $DISTRO main" | tee /etc/apt/sources.list.d/nodesource.list ;\
    echo "deb-src https://deb.nodesource.com/$VERSION $DISTRO main" | tee -a /etc/apt/sources.list.d/nodesource.list;\
	apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        nodejs; \
    rm -rf /var/lib/apt/lists/*; \
    npm i grpc-tools; \
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