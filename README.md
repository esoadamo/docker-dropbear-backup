docker-dropbear-backup
==================================

Allows to serve local disc over SFTP, rsync or borg with user separation and also protocol separation.

Quickstart
------------

To use *docker-dropbear-backup*, follow these steps:

1. Clone and start the container:
   
       git clone https://github.com/esoadamo/docker-dropbear-backup.git &&
       cd docker-dropbear-backup &&
       docker compose up -d

2. Set-up authorized keys to use correct command.

3. Configure your backup software to connect to your *Dropbear* server's IP
   address on port `2222` with user `BACKUP_USER`.

### Variables

The image is configured using environment variables passed at runtime. All these
variables are prefixed by `BACKUP_`.

| Variable | Function                           | Default   | Required |
|:-------- |:---------------------------------- |:--------- | -------- |
| `USER`   | New user that will own the backups | `rbackup` | N        |
| `UID`    | UID of the new user                | 11000     | N        |

#### Authorized keys file

To allow certain users to use the server for backup, we can copy the SSH keys
into the `authorized_keys` file (e. g. `./backups/.ssh/authorized_keys`)
with the format:

    command="/b -u backup -s" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILisX5tOGenRsnuU0jjurld9YMH+z/lSzbehf8OAoSlt test

This will allow user with given SSH public key to access directory `/home/rbackup/u_backup/sftp/` inside directory using SFTP protocol and nothing else. The user will not be able to access any parent directories. Other options for the `/b` script are:

| Option      | Protocol | Description                                                                                          |
|:-----------:|:--------:|:----------------------------------------------------------------------------------------------------:|
| `-u <USER>` | *all*    | Sets internal user, the base directory will be `/home/rbackup/u_<USER>`                              |
| `-s`        | SFTP     | Enables access to SFTP protocol, sanboxed to `/home/rbackup/u_<USER>/sftp/` directory                |
| `-b`        | Borg     | Enables apped-only access to borg repositories, sanboxed to `/home/rbackup/u_<USER>/borg/` directory |
| `-r`        | rsync    | Enables access to rsync protocol, sanboxed to `/home/rbackup/u_<USER>/rsync/` directory              |
| `-a`        | *all*    | Enables access to all protocols                                                                      |
| `-x`        | SFTP     | Enables access to all user files through SFTP, sandboxed to `/home/rbackup/u_<USER>` directory       |
| `-X`        | SFTP     | Enables access to **all container files** through SFTP protocol, no sandboxing enabled               |

You can specify as many authorized keys file line as you wish wish as many users. All the directories will be created automatically upon first use.  Because the command part of the line forces the command to be run, you can then access the container directly through your program:

- `borg init -e repokey "ssh://docker-ip:2222/u_test/borg/my_repo"`
- `rsync /var/backup/ ssh://docker-ip:2222/u_test/rsync/var_backup`
- `sftp docker-ip -P 2222`
