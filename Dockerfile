FROM alpine:3.12

LABEL maintainer="vadim.turkov@gmail.com"

RUN apk add --no-cache \
  curl \
  git \
  openssh-client \
  rsync

ENV VERSION 0.64.0
ENV HUGO_FILE hugo_${VERSION}_Linux-64bit.tar.gz
ENV HUGO_URL https://github.com/gohugoio/hugo/releases/download/v${VERSION}/${HUGO_FILE}
ENV CHECKSUM_URL https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_checksums.txt

WORKDIR /usr/local/src

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN curl -L "${HUGO_URL}" -o "${HUGO_FILE}" \ 
  && curl -L "${CHECKSUM_URL}" | grep "${HUGO_FILE}" | sha256sum -c \
  && tar -xzf "${HUGO_FILE}" \
  && mv hugo /usr/local/bin/hugo \
  && rm -r "${PWD:?}"/* \
  && addgroup -Sg 1000 hugo \
  && adduser -SG hugo -u 1000 -h /src hugo

WORKDIR /src

EXPOSE 1313

HEALTHCHECK --interval=5m --timeout=30s\ 
  CMD curl -f http://localhost:1313/ || exit 1
