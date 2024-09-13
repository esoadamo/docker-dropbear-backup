#!/bin/sh

# Create backup user
if [ "${BACKUP_USER:=rbackup}" ] && ! grep -q -s "^${BACKUP_USER}" /etc/passwd; then
	adduser --shell /bin/sh --uid "${BACKUP_UID:-11000}" --disabled-password "${BACKUP_USER}" && \
	( cd "/home/${BACKUP_USER}" && mkdir -p .ssh && touch .ssh/authorized_keys )
fi

chown -R "${BACKUP_USER}":"${BACKUP_USER}" "/home/${BACKUP_USER}/" && \
chmod 750 "/home/${BACKUP_USER}/.ssh" && \
chmod 640 "/home/${BACKUP_USER}/.ssh/authorized_keys" &&

chown root:"${BACKUP_USER}" /rclone.conf &&
chmod 640 /rclone.conf &&

# Start SSH server
/usr/sbin/dropbear "$@"
