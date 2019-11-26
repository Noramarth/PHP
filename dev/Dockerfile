FROM aomgroup/cli-base:base-7.3.11-0.0.3-latest

RUN curl -fsSL -o composer.phar 'https://getcomposer.org/composer.phar'; \
    ls -lsa; \
    mv composer.phar /usr/bin/composer; \
    chmod +x /usr/bin/composer;
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    git;

USER app
RUN composer global require hirak/prestissimo