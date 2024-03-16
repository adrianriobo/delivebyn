FROM registry.access.redhat.com/ubi9/ubi-minimal@sha256:bc552efb4966aaa44b02532be3168ac1ff18e2af299d0fe89502a1d9fabafbc5

LABEL org.opencontainers.image.authors="Adrian Riobo <ariobolo@redhat.com>"

RUN microdnf install -y openssh-clients sshpass zip jq

COPY lib/* entrypoint.sh /usr/local/bin/

ENTRYPOINT ["entrypoint.sh"]