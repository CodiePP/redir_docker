# DOCKER_BUILDKIT=1 docker buildx build --push --platform linux/amd64,linux/arm64 --tag codieplusplus/redir_docker:latest .

FROM alpine:latest AS build-env

LABEL org.opencontainers.image.source="https://github.com/CodiePP/redir_docker"

RUN addgroup -g 1000 user \
    && adduser -u 1000 -G user -s /bin/bash -D user \
    && apk update \
    && apk add --no-cache bash git alpine-sdk autoconf automake

USER user

WORKDIR /home/user

RUN git clone https://github.com/troglobit/redir redir.git

RUN cd redir.git && ./autogen.sh && ./configure && make && strip -s redir

#####

FROM alpine:latest

RUN addgroup -g 1000 user \
    && adduser -u 1000 -G user -s /bin/bash -D user \
    && apk update \
    && apk add --no-cache bash

COPY --chown=1000 --from=build-env /home/user/redir.git/redir /home/user/redir

USER user

WORKDIR /home/user

CMD bash

