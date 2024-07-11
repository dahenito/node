# syntax=docker/dockerfile:1

ARG VERSION=22.4.1

###
FROM alpine:3.20 AS builder
RUN apk add --no-cache bash curl file tar xz zip

ARG VERSION
ARG HOSTOS
ARG HOSTARCH

WORKDIR /app
#
ENV VERSION=${VERSION}
ENV HOSTOS=${HOSTOS}
ENV HOSTARCH=${HOSTARCH}

COPY ./setup.sh /setup.sh

RUN /setup.sh

COPY install uninstall /egress/

#
CMD [ "bash" ]
