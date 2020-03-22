FROM aomgroup/cli-base:base-7.4.4-0.0.3-latest
RUN curl -fsSL -o composer.phar 'https://getcomposer.org/composer.phar'; \
    mv composer.phar /usr/bin/composer; \
    chmod +x /usr/bin/composer;
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    git \
    unzip;
USER app
RUN composer global require hirak/prestissimo
CMD ["php", "-a"]