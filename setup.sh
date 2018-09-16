#!/bin/sh

cd /var/www/sylius

# Sylius setup
composer install --no-interaction
php bin/console sylius:install --no-interaction
yarn install
yarn run gulp

# TV setup
php bin/console sylius:theme:assets:install --symlink
php bin/console tv:install:setup
php bin/console tv:import:products