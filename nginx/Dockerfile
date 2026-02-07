FROM nginxinc/nginx-unprivileged:1.29.5-trixie

# We "normalize" the nginx unprivileged image into what we normally have (user www-data) and /var/www/html
USER root
RUN chown -R www-data:www-data /var/cache/nginx \
    && chmod -R g+w /var/cache/nginx \
    && chown -R www-data:www-data /etc/nginx \
    && rm -rf /usr/share/nginx/html \
    && ln -s /var/www/html /usr/share/nginx/html

USER www-data
WORKDIR /var/www/html
