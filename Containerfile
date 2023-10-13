FROM registry.hub.docker.com/library/alpine:3.18.4@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978

LABEL org.opencontainers.image.authors="Adrian Riobo <ariobolo@redhat.com>"

RUN apk --no-cache add openssh-client sshpass zip bash curl

COPY lib/* entrypoint.sh /usr/local/bin/

ENTRYPOINT ["entrypoint.sh"]