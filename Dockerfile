FROM alpine:3.19.0

RUN apk add --no-cache \
        ca-certificates \
        ansible \
        py3-kubernetes \
        py3-yaml \
        py3-jsonpatch \
        curl \
        openssl

RUN curl -sL https://talos.dev/install | sh

RUN ansible-galaxy install -r requirements.yml
