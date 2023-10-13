FROM registry.hub.docker.com/library/alpine:3.18.4

LABEL org.opencontainers.image.authors="Adrian Riobo <ariobolo@redhat.com>"

RUN apk --no-cache add openssh-client sshpass zip bash curl

COPY lib/* entrypoint.sh /usr/local/bin/

ENTRYPOINT ["entrypoint.sh"]