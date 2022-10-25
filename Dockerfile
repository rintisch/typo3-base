####################################################
# Improved with https://hadolint.github.io/hadolint/
####################################################

FROM nginx:1.21.6

ARG TOKEN 
ARG ROOT_PATH=/var/www/html
ARG LOCALE_LANG_COUNTRY="de_DE"
ARG LOCALE_CODIFICATION="UTF-8"

ARG SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.9/supercronic-linux-amd64
ARG SUPERCRONIC=supercronic-linux-amd64
ARG SUPERCRONIC_SHA1SUM=5ddf8ea26b56d4a7ff6faecdd8966610d5cb9d85

# Variables for supercronic, TYPO3, PHP
ENV TYPO3_CONTEXT=Production/Live \
    PHP_INI_SCAN_DIR=/etc/php/8.1/fpm/conf.d

# see https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# Install needed packages, set time zone
RUN apt-get update && \
    apt-get install -yqq --no-install-recommends --no-install-suggests \
        apache2-utils \
        apt-transport-https \
        bash \
        ca-certificates \
        curl \
        ghostscript \
        git \
        gnupg2 \
        less \
        libgs-dev \
        locales \
        logrotate \
        lsb-release \
        imagemagick\
        msmtp \
        openrc \
        tini \
        vim \
        zip \
        xfonts-75dpi xfonts-base gvfs colord glew-utils libvisual-0.4-plugins gstreamer1.0-tools opus-tools qt5-image-formats-plugins qtwayland5 qt5-qmltooling-plugins librsvg2-bin lm-sensors \
        supervisor \
        wget && \
        # add sury repository to install wanted php version
        # !!! changes of php version must also be done in `supervisord.conf` and in `./etc/php/*`
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
        php8.1 \
        php8.1-apcu \
        php8.1-cli \
        php8.1-common \
        php8.1-curl \
        php8.1-dom \
        php8.1-fpm \
        php8.1-gd \
        php8.1-intl \
        php8.1-mbstring \
        php8.1-mysql \
        php8.1-opcache \
        php8.1-pdo \
        php8.1-pgsql \
        php8.1-redis \
        php8.1-sqlite3 \
        php8.1-tokenizer \
        php8.1-xml \
        php8.1-zip && \
    # Install composer:
    # Get it and hash; install if hash is verified; install globally; delete created install file
    curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    HASH=$(curl -sS https://composer.github.io/installer.sig) && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Composer Installer verified'; } else { echo 'Composer Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    # Install yarn & nodejs v16
    curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install --no-install-recommends  --no-install-suggests -y\
        yarn \
        nodejs && \
    # set timezone
    cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    # install supercronic for cron job
    curl -fsSLO "$SUPERCRONIC_URL" && \
    echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - && \
    chmod +x "$SUPERCRONIC" && \
    mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" && \
    ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic && \
    # run sed (=Stream EDitor) to enable rendering of pictures from images by ImageMagick
    sed -i 's/<policy domain="coder" rights="none" pattern="PDF" \/>/<!-- <policy domain="coder" rights="none" pattern="PDF" \/> -->/g' /etc/ImageMagick-6/policy.xml && \
    # remove cache
    apt-get autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*

    # Directory /run/php is needed for php8.1-fpm.sock
    RUN mkdir -p /run/php && \
    # Directory /nonexistent which is needed for "composer config -g ..."
    mkdir -p /nonexistent && \
    chown nginx:nginx /nonexistent && \
    # Set locale language
    localedef -i ${LOCALE_LANG_COUNTRY} -c -f ${LOCALE_CODIFICATION} -A /usr/share/locale/locale.alias ${LOCALE_LANG_COUNTRY}.${LOCALE_CODIFICATION} && \
    # Create volume folder
    mkdir -p ${ROOT_PATH}/public/typo3temp && \
    mkdir -p ${ROOT_PATH}/public/fileadmin && \
    mkdir -p ${ROOT_PATH}/public/uploads && \
    mkdir -p ${ROOT_PATH}/config/sites && \
    mkdir -p ${ROOT_PATH}/var/labels

# Copy server configuration 
COPY etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY etc/nginx/conf.d/default-base.conf /etc/nginx/conf.d/default-base.conf
COPY etc/php /etc/php
COPY etc/crontab /etc/crontab
COPY etc/logrotate.d /etc/logrotate.d
COPY etc/supervisord.conf /etc/supervisord.conf

# Configure volumes
VOLUME ${ROOT_PATH}/public/fileadmin
VOLUME ${ROOT_PATH}/public/typo3temp
VOLUME ${ROOT_PATH}/public/uploads
VOLUME ${ROOT_PATH}/var/labels
VOLUME ${ROOT_PATH}/config/sites