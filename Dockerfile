FROM alpine:3.12

ARG CREATE_DATE
ARG REVISION
ARG BUILD_VERSION

ENV VERSION 0.64.0

LABEL maintainer="vadim.turkov@gmail.com"
LABEL org.opencontainers.image.create_date=$CREATE_DATE
LABEL org.opencontainers.image.title="hugo_builder"
LABEL org.opencontainers.image.source="https://github.com/vadimturkov/docker-container-security-lp"
LABEL org.opencontainers.image.revision=$REVISION
LABEL org.opencontainers.image.version=$BUILD_VERSION
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL hugo_version=$VERSION

RUN apk add --no-cache \
  curl \
  git \
  openssh-client \
  rsync

WORKDIR /usr/local/src

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN curl -OL "https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_Linux-64bit.tar.gz" \ 
  && curl -L "https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_checksums.txt" \
  | grep "hugo_${VERSION}_Linux-64bit.tar.gz" | sha256sum -c \
  && tar -xzf "hugo_${VERSION}_Linux-64bit.tar.gz" \
  && mv hugo /usr/local/bin/hugo \
  && rm -rf "${PWD}" \
  && addgroup -Sg 1000 hugo \
  && adduser -SG hugo -u 1000 -h /src hugo

WORKDIR /src

EXPOSE 1313

USER hugo

HEALTHCHECK --interval=10s --timeout=10s --start-period=15s \ 
  CMD hugo env || exit 1
