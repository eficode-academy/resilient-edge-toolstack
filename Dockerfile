FROM alpine:latest

RUN apk add --no-cache \
        ca-certificates \
        ansible \
        py3-kubernetes \
        py3-yaml \
        py3-jsonpatch \
        curl \
        openssl \
        helm \
        kubectl

RUN curl -sL https://talos.dev/install | sh

RUN ansible-galaxy collection install kubernetes.core
