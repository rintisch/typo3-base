####################################################
# Improved with https://hadolint.github.io/hadolint/
####################################################

FROM nginx:1.25.1

ARG TOKEN 
ARG ROOT_PATH=/var/www/html
ARG LOCALE_LANG_COUNTRY="de_DE"
ARG LOCALE_CODIFICATION="UTF-8"

# Install instructions for supercronic: https://github.com/aptible/supercronic/releases
ARG SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.1/supercronic-linux-amd64
ARG SUPERCRONIC=supercronic-linux-amd64
ARG SUPERCRONIC_SHA1SUM=d7f4c0886eb85249ad05ed592902fa6865bb9d70

# Variables for supercronic, TYPO3, PHP
ENV TYPO3_CONTEXT=Production/Live \
    PHP_INI_SCAN_DIR=/etc/php/8.2/fpm/conf.d

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
        gnupg \
        gnupg2 \
        imagemagick\
	iputils-ping \
        less \
        libgs-dev \
        locales \
        logrotate \
        lsb-release \
        msmtp \
        openrc \
	patch \
        supervisor \
        tini \
        unzip \
        vim \
        wget \
        xfonts-75dpi xfonts-base gvfs colord glew-utils libvisual-0.4-plugins gstreamer1.0-tools opus-tools qt5-image-formats-plugins qtwayland5 qt5-qmltooling-plugins librsvg2-bin lm-sensors \
        zip && \
        # add sury repository to install wanted php version
        # !!! changes of php version must also be done in `supervisord.conf` and in `./etc/php/*`
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
        php8.2 \
        php8.2-apcu \
        php8.2-cli \
        php8.2-common \
        php8.2-curl \
        php8.2-dom \
        php8.2-fpm \
        php8.2-gd \
        php8.2-intl \
        php8.2-mbstring \
        php8.2-mysql \
        php8.2-opcache \
        php8.2-pdo \
        php8.2-pgsql \
        php8.2-redis \
        php8.2-sqlite3 \
        php8.2-tokenizer \
        php8.2-xml \
        php8.2-zip && \
    # Install composer:
    # Get it and hash; install if hash is verified; install globally; delete created install file
    curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    HASH=$(curl -sS https://composer.github.io/installer.sig) && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Composer Installer verified'; } else { echo 'Composer Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    # Install nodejs v20 (npm is included)
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    NODE_MAJOR=20 && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install --no-install-recommends  --no-install-suggests -y \
      nodejs && \
    node -v && \
    npm -v && \
    # Install yarn (for backwards compatibility, should be dropped in v4)
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install --no-install-recommends  --no-install-suggests -y\
        yarn && \
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

    # Directory /run/php is needed for php8.2-fpm.sock
    RUN mkdir -p /run/php && \
    # Directory /nonexistent which is needed for "composer config -g ..."
    mkdir -p /nonexistent && \
    chown nginx:nginx /nonexistent && \
    # Set locale language
    localedef -i ${LOCALE_LANG_COUNTRY} -c -f ${LOCALE_CODIFICATION} -A /usr/share/locale/locale.alias ${LOCALE_LANG_COUNTRY}.${LOCALE_CODIFICATION} && \
    # Create volume folder
    mkdir -p ${ROOT_PATH}/public/typo3temp && \
    mkdir -p ${ROOT_PATH}/public/fileadmin && \
    mkdir -p ${ROOT_PATH}/public/uploads

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
