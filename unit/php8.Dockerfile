FROM unit:php8.4@sha256:421c93e3d778a282ecf347bf71d6b494b58600a87b90389fd61d08f8a7388ed7

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
ADD --chmod=0755 https://github.com/wp-cli/wp-cli/releases/download/v2.12.0/wp-cli-2.12.0.phar /usr/local/bin/wp

ARG PHP_EXTENSIONS
RUN if [ ! -z "PHP_EXTENSIONS" ]; then install-php-extensions $PHP_EXTENSIONS; fi

# Packages that are NOT required to install php-extensions!
ARG DEBIAN_PACKAGES
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    if [ ! -z "DEBIAN_PACKAGES" ]; then \
        apt-get update && apt-get install -y --no-install-recommends \
        $DEBIAN_PACKAGES \
    ; fi \
    && rm -rf /var/lib/apt/lists/*
