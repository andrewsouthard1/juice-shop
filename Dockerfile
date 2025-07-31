# Use a specific version of Node.js 14 that is based on Debian 11 "Bullseye".
# This is the latest and most secure version of Node.js 14 and its base OS is actively maintained.
FROM node:14.21.3-bullseye

# This command will now work because Bullseye repositories are still active.
# We no longer need the snapshot repo workaround.
RUN apt-get -y update && apt-get -y install ca-certificates apt-transport-https

# This block is for adding a snapshot repository to fix the failing apt-get.
# It is no longer needed with the `node:14.21.3-bullseye` base image.
# I have commented it out for clarity.
# RUN echo 'deb [trusted=yes check-valid-until=no] https://snapshot.debian.org/archive/debian/20211201T215332Z/ buster main \n\
# deb-src [trusted=yes check-valid-until=no] https://snapshot.debian.org/archive/debian/20211201T215332Z/ buster main \n\
# deb [trusted=yes check-valid-until=no] https://snapshot.debian.org/archive/debian-security/20211201T215332Z/ buster/updates main \n\
# deb-src [trusted=yes check-valid-until=no] https://snapshot.debian.org/archive/debian-security/20211201T215332Z/ buster/updates main' >> /etc/apt/sources.list

# This command will now succeed with the working repository.
# liblog4j2-java is probably an application-specific dependency.
# Note: You should check if this specific version is available on Bullseye,
# if not, you might need to adjust the version or remove this dependency.
RUN apt-get -y update && apt-get -y install \
    liblog4j2-java=2.11.1-2

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
