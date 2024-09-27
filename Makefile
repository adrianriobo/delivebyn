VERSION ?= 0.0.7
CONTAINER_MANAGER ?= podman
IMG ?= quay.io/rhqp/deliverest:v${VERSION}

.PHONY: oci-build
oci-build: 
	${CONTAINER_MANAGER} build -t ${IMG} -f Containerfile .

.PHONY: oci-push
oci-push:
	${CONTAINER_MANAGER} push ${IMG}