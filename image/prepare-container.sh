#!/bin/sh
set -e

# Warning : this no standard docker entrypoint, we use dumb-init !
ensureKeyAlgo() {
  if [ ! -f "/etc/ssh/ssh_host_${1}_key" ]; then
    # generate fresh $1 key
    ssh-keygen -f /etc/ssh/ssh_host_${1}_key -N '' -t "${1}"
  fi
}
ensureKeyAlgo ed25519
ensureKeyAlgo rsa
ensureKeyAlgo ecdsa
[[ -f /etc/sshd_config ]] && mv /etc/sshd_config /etc/ssh/sshd_config || [[ -f /etc/ssh/sshd_config ]]
chmod -w /etc/ssh/sshd_config

echo -n "$HIGHLIGHT_THEME" > /.highlight-theme

# prepare run dir
if ! [[ -d "/var/run/sshd" ]]; then
  mkdir -p /var/run/sshd
fi

# Run sshd
echo "Starting sshd"
/usr/sbin/sshd

# Volume permissions
echo "Setting up permissions"
mkdir -p /var/lib/git/.gitolite/logs
chown -R git /var/lib/git
chgrp -R www-data /var/lib/git
chmod -R 775 /var/lib/git

# If no cgitrc, let's copy one from /etc/cgitrc.default. This happens when bindmounting /var/lib/git
if [ ! -f "/var/lib/git/cgitrc" ]; then
	echo '# This is an autogenrated file. Do not edit it by hand, changes will be lost.' | cat - /etc/cgitrc.default > /var/lib/git/cgitrc
  chown git /var/lib/git/cgitrc
  chmod 711 /var/lib/git/cgitrc
fi
if [ ! -f "/var/lib/git/.ssh/authorized_keys" ]; then
  # Gitolite configuration (admin pubkey)
  if [ -n "$SSH_KEY" ]; then
    echo "$SSH_KEY" > "/tmp/admin.pub"
    su - git -c "gitolite setup -pk \"/tmp/admin.pub\""
    rm "/tmp/admin.pub"
  else
    echo "You need to specify SSH_KEY on first run to setup gitolite"
    echo 'Example: podman run --rm -dit -v git-data:/var/lib/git -v git-ssh:/etc/ssh -e SSH_KEY="$(cat /home/<user>/.ssh/id_rsa.pub)" gjbs84/gitolite-cgit:latest'
    exit 1
  fi
  echo "First launch: container is now shut down"
  halt
else
  # Check setup at every startup
  su - git -c "gitolite setup"
fi

#exec "$@"
