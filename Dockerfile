FROM node:14 AS build

COPY package.json package-lock.json /app/

WORKDIR /app/

RUN npm install

COPY ./ /app/

RUN make

RUN mkdir -p /out/rootfs/usr/share/jitsi-meet/css/ \
             /out/rootfs/usr/share/jitsi-meet/scripts/ \
             /out/rootfs/defaults/ \
 # jitsi-meet-web
 && cp -rf *.html \
           connection_optimization/ \
           favicon.ico \
           fonts/ \
           images/ \
           lang/ \
           libs/ \
           LICENSE \
           logging_config.js \
           resources/robots.txt \
           sounds/ \
           static/ \
       /out/rootfs/usr/share/jitsi-meet/ \
 && cp -rf css/all.css \
       /out/rootfs/usr/share/jitsi-meet/css/ \
 && cp -rf resources/*.sh \
       /out/rootfs/usr/share/jitsi-meet/scripts/ \
 # jitsi-meet-web-config
 && cp -rf config.js \
           interface_config.js \
       /out/rootfs/defaults/




FROM jitsi/base:latest AS runtime

ADD https://dl.eff.org/certbot-auto /usr/local/bin/

COPY docker/rootfs/ /
COPY --from=build /out/rootfs/ /

RUN apt-dpkg-wrap apt-get update \
 && apt-dpkg-wrap apt-get install -y cron nginx-extras \
 && apt-cleanup \
 && rm -rf /etc/nginx/conf.d/default.conf \
           /var/cache/apt

RUN chmod a+x /usr/local/bin/certbot-auto \
 && certbot-auto --noninteractive --install-only

EXPOSE 80 443

VOLUME ["/config", "/etc/letsencrypt", "/usr/share/jitsi-meet/transcripts"]