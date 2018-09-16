FROM sylius/nginx-php-fpm:latest
MAINTAINER Sylius Docker Team <docker@sylius.org>

ARG AS_UID=33

ENV SYLIUS_VERSION 1.1.1

ENV BASE_DIR /var/www
ENV SYLIUS_DIR ${BASE_DIR}/sylius

# Modify UID of www-data into UID of local user
RUN usermod -u ${AS_UID} www-data

# Install GD
RUN apt-get update && apt-get install -y \
  libpng-dev \
  libfreetype6-dev \
  libjpeg-dev \
  libxpm-dev \
  libxml2-dev \
  libxslt-dev \
  libmcrypt-dev \
  libwebp-dev  # php >=7.0 (use libvpx for php <7.0)
RUN docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
    --with-xpm-dir=/usr/include \
    --with-webp-dir=/usr/include/ # php >=7.0 (use libvpx for php <7.0)
RUN docker-php-ext-install gd

# Install yarn
RUN curl -sS http://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -sL http://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs
RUN apt-get install -y yarn

# Copy project files
ADD ./sylius ${SYLIUS_DIR}
ADD ./setup.sh ${SYLIUS_DIR}/setup.sh

WORKDIR ${BASE_DIR}

RUN cd ${SYLIUS_DIR} \
	&& chown -R www-data: . \
	&& chmod +x bin/console \
	&& chmod +x setup.sh

# entrypoint.d scripts
COPY entrypoint.d/* /entrypoint.d/

# nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/sylius_params /etc/nginx/sylius_params

RUN chown www-data.www-data /etc/nginx/sylius_params


