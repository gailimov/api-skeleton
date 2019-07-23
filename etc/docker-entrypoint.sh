#!/bin/sh

j2 /rr.yaml.j2 > /etc/rr.yaml

if [ "$ENV" == 'dev' ]; then
    composer install
fi

exec "$@"
