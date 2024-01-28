#!/bin/sh

# Wrapper for $SSH_ORIGINAL_COMMAND

# Get binary
SSH_COMMAND_BIN="${SSH_ORIGINAL_COMMAND%% *}"

if [ -n "$BACKUP_USER" ]; then
	BACKUP_USER="u_$BACKUP_USER"
else
	BACKUP_USER="root"
fi

# Create user home directories
DIR_BORG="$HOME/$BACKUP_USER/borg/"
DIR_RSYNC="$HOME/$BACKUP_USER/rsync/"
DIR_SFTP="$HOME/$BACKUP_USER/sftp/"

mkdir -p "$DIR_BORG" || true
mkdir -p "$DIR_RSYNC" || true
mkdir -p "$DIR_SFTP" || true

# Launch the process
case "${SSH_COMMAND_BIN}" in
	*borg)
		/usr/bin/borg serve --append-only --restrict-to-path "$DIR_BORG"
		;;
	*rsync)
		/usr/bin/rrsync "$DIR_RSYNC"
		;;
	*sftp-server)
		# /usr/lib/ssh/sftp-server -d "$DIR_SFTP"
		printf "SFTP disabled\n" >&2
		exit 1
		;;
	*)
		printf "Access denied\n" >&2
		exit 1
		;;
esac
