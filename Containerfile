FROM quay.io/fedora/fedora:42@sha256:27a856861d809e83cf720d94a31a6e45120e6875536602c355f027ce1df5c902

LABEL org.opencontainers.image.authors="CRCQE <devtools-cdkqe@redhat.com>"

RUN dnf install -y openssh-clients sshpass zip jq

COPY lib/common/* lib/os/ entrypoint.sh /usr/local/bin/

ENTRYPOINT ["entrypoint.sh"]