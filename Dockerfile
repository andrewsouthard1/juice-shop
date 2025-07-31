# Start with the Node 14 image on Debian Bullseye.
FROM node:14.21.3-bullseye

# First, run an apt-get update to prepare for other installations.
RUN apt-get -y update && apt-get -y install ca-certificates apt-transport-https wget

# Download the specific .deb package for the vulnerable version from the Debian snapshot archive.
# We use `wget` for this. The URL is crucial.
RUN wget http://snapshot.debian.org/archive/debian/20211201T215332Z/pool/main/l/log4j2/liblog4j2-java_2.11.1-2_all.deb -O /tmp/liblog4j2.deb

# Manually install the downloaded package using `dpkg`.
# `dpkg` is the low-level tool for installing packages and doesn't rely on the repositories.
# We also use `apt-get install -f` afterwards to resolve any potential dependencies.
RUN dpkg -i /tmp/liblog4j2.deb || apt-get -y install -f

# Clean up the downloaded file to keep the image size down.
RUN rm /tmp/liblog4j2.deb

ARG BUILD_DATE
ARG VCS_REF
LABEL maintainer="Bjoern Kimminich <bjoern.kimminich@owasp.org>" \
    org.opencontainers.image.title="OWASP Juice Shop" \
    org.opencontainers.image.description="Probably the most modern and sophisticated insecure web application" \
    org.opencontainers.image.authors="Bjoern Kimminich <bjoern.kimminich@owasp.org>" \
    org.opencontainers.image.vendor="Open Web Application Security Project" \
    org.opencontainers.image.documentation="https://help.owasp-juice.shop" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.version="12.3.0" \
    org.opencontainers.image.url="https://owasp-juice.shop" \
    org.opencontainers.image.source="https://github.com/clintonherget/juice-shop" \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.created=$BUILD_DATE \
    io.snyk.containers.image.dockerfile="/Dockerfile"

RUN addgroup --system --gid 1001 juicer && \
    adduser juicer --system --uid 1001 --ingroup juicer
COPY --chown=juicer . /juice-shop
WORKDIR /juice-shop
RUN npm install --production --unsafe-perm
RUN npm dedupe
RUN rm -rf frontend/node_modules
RUN mkdir logs && \
    chown -R juicer logs && \
    chgrp -R 0 ftp/ frontend/dist/ logs/ data/ i18n/ && \
    chmod -R g=u ftp/ frontend/dist/ logs/ data/ i18n/
USER 1001
EXPOSE 3000
CMD ["npm", "start"]
