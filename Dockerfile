ARG BASE_IMAGE=library/alpine:latest

FROM docker.io/${BASE_IMAGE}

RUN \
  apk add --update --no-cache dropbear borgbackup openssh-sftp-server rrsync bubblewrap rclone \
  && rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh
COPY bin/ssh_command.sh /usr/local/bin/ssh_command.sh
COPY rclone.conf /rclone.conf
RUN chmod +x /usr/local/bin/ssh_command.sh && \
    ln -s /usr/local/bin/ssh_command.sh /b

EXPOSE 22/tcp

VOLUME /etc/dropbear

HEALTHCHECK --interval=1m --timeout=3s \
  CMD timeout 2 nc 127.0.0.1 22 | grep -qE "^SSH.*dropbear"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["-RFEmwsgkj", "-p", "22"]
