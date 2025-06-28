ARG VARIANT=
FROM php:7.4.32${VARIANT}

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/


RUN install-php-extensions \
    redis \
    gd \
    bcmath \
    exif \
    intl \
    mysqli \
    pgsql \
    zip \
    imagick/imagick@master \
    opcache

# Packages that are NOT required to install php-extensions!
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    # We want to easily send email, this was the smallest mail client with sendmail
    msmtp-mta \
    && rm -rf /var/lib/apt/lists/*

