FROM registry.access.redhat.com/ubi9/ubi-minimal

LABEL org.opencontainers.image.authors="Adrian Riobo <ariobolo@redhat.com>"

RUN microdnf install -y openssh-clients sshpass zip jq

COPY lib/* entrypoint.sh /usr/local/bin/

ENTRYPOINT ["entrypoint.sh"]