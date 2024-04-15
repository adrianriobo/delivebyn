FROM quay.io/fedora/fedora:40

LABEL org.opencontainers.image.authors="CRCQE <devtools-cdkqe@redhat.com>"

RUN dnf install -y openssh-clients sshpass zip jq

COPY lib/common/* lib/os/ entrypoint.sh /usr/local/bin/

ENTRYPOINT ["entrypoint.sh"]