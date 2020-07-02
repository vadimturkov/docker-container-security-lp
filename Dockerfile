FROM alpine:3.12

LABEL maintainer="vadim.turkov@gmail.com"

RUN apk add --no-cache \
  curl \
  git \
  openssh-client \
  rsync

ENV VERSION 0.64.0

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

HEALTHCHECK --interval=10s --timeout=10s --start-period=15s \ 
  CMD hugo env || exit 1
