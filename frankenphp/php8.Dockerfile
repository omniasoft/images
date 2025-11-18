FROM dunglas/frankenphp:1.9.1-php8.4.14-trixie


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

ADD --chmod=0755 https://github.com/wp-cli/wp-cli/releases/download/v2.12.0/wp-cli-2.12.0.phar /usr/local/bin/wp

# Unprivileged and without capabilities using default www-data user in debian
RUN setcap -r /usr/local/bin/frankenphp; \
	chown -R www-data:www-data /config/caddy /data/caddy
USER www-data

