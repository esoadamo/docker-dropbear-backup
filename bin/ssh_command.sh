#!/bin/sh

# Wrapper for $SSH_ORIGINAL_COMMAND

# Get binary
SSH_COMMAND_BIN="${SSH_ORIGINAL_COMMAND%% *}"

BACKUP_USER="root"
SFTP_ENABLE="no"
SFTP_PERMISSIONS="sandbox"
BORG_ENABLE="no"
RSYNC_ENABLE="no"

while getopts "Xxabrsu:" o; do
  case "${o}" in
  u)
    BACKUP_USER="u_$OPTARG"
    ;;
  s)
    SFTP_ENABLE="yes"
    ;;
  b)
    BORG_ENABLE="yes"
    ;;
  r)
    RSYNC_ENABLE="yes"
    ;;
  a)
    SFTP_ENABLE="yes"
    BORG_ENABLE="yes"
    RSYNC_ENABLE="yes"
    ;;
  x)
    SFTP_PERMISSIONS="all-user-files"
    ;;
  X)
    SFTP_PERMISSIONS="all-files"
    ;;
  *)
	printf "Invalid config option\n" >&2
	exit 1
    ;;
  esac
done
shift $((OPTIND - 1))

# Create user home directories
DIR_USER="$HOME/$BACKUP_USER"
DIR_BORG="$DIR_USER/borg/"
DIR_RSYNC="$DIR_USER/rsync/"
DIR_SFTP="$DIR_USER/sftp/"

mkdir -p "$DIR_BORG"
mkdir -p "$DIR_RSYNC"
mkdir -p "$DIR_SFTP"

# Launch the process
case "${SSH_COMMAND_BIN}" in
	*borg)
		if [ "$BORG_ENABLE" != "yes" ]; then
			printf "BORG disabled\n" >&2
			exit 1
		fi
		/usr/bin/borg serve --append-only --restrict-to-path "$DIR_BORG"
		;;
	*rsync)
		if [ "$RSYNC_ENABLE" != "yes" ]; then
			printf "RSYNC disabled\n" >&2
			exit 1
		fi
		/usr/bin/rrsync "$DIR_RSYNC"
		;;
	*sftp-server)
		if [ "$SFTP_ENABLE" != "yes" ]; then
			printf "SFTP disabled\n" >&2
			exit 1
		fi

		if [ "$SFTP_PERMISSIONS" == "all-files" ]; then
			/usr/lib/ssh/sftp-server -d "$DIR_SFTP"
			exit $?
		fi

		SFTP_ROOT_DIR="$DIR_SFTP"
		SFTP_STARTING_DIR="$HOME"

		if [ "$SFTP_PERMISSIONS" == "all-user-files" ]; then
			SFTP_ROOT_DIR="$DIR_USER"
			SFTP_STARTING_DIR="$HOME/sftp"
		fi

		bwrap --die-with-parent \
		    --ro-bind /usr /usr \
			--ro-bind /etc /etc \
			--ro-bind /var /var \
			--ro-bind /lib /lib \
			--ro-bind /bin /bin \
			--dev /dev \
			--unshare-pid \
			--tmpfs /home \
			--tmpfs /tmp \
			--tmpfs /var/tmp \
			--bind "$SFTP_ROOT_DIR" "$HOME" \
			/usr/lib/ssh/sftp-server -d "$SFTP_STARTING_DIR"
		;;
	*)
		printf "Access denied, unknown command\n" >&2
		exit 1
		;;
esac
