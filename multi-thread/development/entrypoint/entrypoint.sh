#!/bin/bash

chown -R app:app /app
chmod -R 777 /app/

php-fpm
