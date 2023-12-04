FROM registry.hub.docker.com/library/alpine:3.18.5@sha256:34871e7290500828b39e22294660bee86d966bc0017544e848dd9a255cdf59e0

LABEL org.opencontainers.image.authors="Adrian Riobo <ariobolo@redhat.com>"

RUN apk --no-cache add openssh-client sshpass zip bash curl

COPY lib/* entrypoint.sh /usr/local/bin/

ENTRYPOINT ["entrypoint.sh"]