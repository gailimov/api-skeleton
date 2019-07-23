FROM php:7.3-alpine3.10

RUN apk add -U \
        autoconf \
        build-base \
        py-pip \
    && pip install j2cli

ARG ENV
RUN if [ "$ENV" == 'dev' ]; then \
        pecl install xdebug; \
        docker-php-ext-enable xdebug; \
        echo "xdebug.remote_enable=1" >> ${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini; \
        echo "xdebug.remote_autostart=1" >> ${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini; \
    fi

ENV COMPOSER_ALLOW_SUPERUSER 1
COPY --from=composer:1.8 /usr/bin/composer /usr/bin/composer

ENV RR_VERSION 1.4.6
RUN wget https://github.com/spiral/roadrunner/releases/download/v${RR_VERSION}/roadrunner-${RR_VERSION}-linux-amd64.tar.gz && \
    tar -zxvf roadrunner-${RR_VERSION}-linux-amd64.tar.gz && \
    mv roadrunner-${RR_VERSION}-linux-amd64/rr /bin && \
    rm -r roadrunner-${RR_VERSION}-linux-amd64

COPY . /app
WORKDIR /app

RUN if [ "$ENV" != 'dev' ]; then \
        composer install --no-dev --classmap-authoritative; \
    fi

COPY etc/rr.yaml.j2 /
COPY etc/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD [ "rr", "serve", "-v", "-d", "-c", "/etc/rr.yaml" ]
