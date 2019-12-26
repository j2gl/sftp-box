FROM alpine:latest

LABEL MAINTAINER=j2gl

RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk add --no-cache bash shadow@community openssh openssh-sftp-server

RUN sed -i 's/GROUP=1000/GROUP=100/' /etc/default/useradd && \
    mkdir -p /var/run/sshd

COPY conf/sshd_config /etc/ssh
COPY conf/banner.txt /etc/ssh
COPY ./docker-entrypoint.sh /


EXPOSE 22

ENTRYPOINT ["/docker-entrypoint.sh"]
