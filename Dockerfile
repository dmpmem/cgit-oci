FROM docker.io/alpine:latest AS base

WORKDIR /root

# Packages we'll keep
RUN apk upgrade --no-cache && \
    apk add --no-cache \
            git openssh \
            python3 py3-pygments \
            py3-markdown \
            libintl musl-libintl \
            zlib \
            caddy \
            cgit gitolite \
            openssl \
            dumb-init \
            fcgiwrap \
            sudo zsh openrc \
            libcap

ADD image/prepare-container.sh /usr/local/bin/prepare-container.sh
ADD image/fcgiwrap-launcher /usr/local/bin/fcgiwrap-launcher
RUN chmod +x /usr/local/bin/prepare-container.sh /usr/local/bin/fcgiwrap-launcher

# SSHD config : no password, no strict mode
# Moved by prepare-container.sh
ADD image/sshd_config /etc/sshd_config

# CGIT Config
# Copied by prepare-container.sh
ADD image/cgitrc /etc/cgitrc.default

# Caddy config
ADD image/Caddyfile /etc/caddy/Caddyfile

# Remove SSH keyes, fresh keys will be generated at container startup by prepare-container.sh
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

# Gitolis / Gitolite
RUN adduser -D -g "" -s "/bin/ash" http
RUN addgroup git www-data && addgroup git http
RUN addgroup http www-data && addgroup http git
# We need a password set, otherwise pubkey auth doesn't work... why ?? /sbin/nologin doesn't work either
RUN echo "git:$(openssl rand -hex 4096)" | chpasswd

# Caddy needs CAP_NET_BIND_SERVICE
RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/caddy

RUN ln -s /var/lib/git/cgitrc /etc/cgitrc

# SSH Keys, Config
VOLUME ["/etc/ssh"]
# Git Directories
VOLUME ["/var/lib/git"]

# CGit
EXPOSE 80
# SSH
EXPOSE 22

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["sh", "-c", "/usr/local/bin/prepare-container.sh && sh -c 'sleep 3 && chgrp www-data /run/fcgiwrap/fcgiwrap.sock && chmod g+w /run/fcgiwrap/fcgiwrap.sock && exec sudo -u http /usr/sbin/caddy run --config /etc/caddy/Caddyfile --adapter caddyfile' & /usr/local/bin/fcgiwrap-launcher"]

FROM base AS with-fmt
RUN apk add --no-cache py3-markdown py3-docutils groff
RUN echo -e 'about-filter=/usr/lib/cgit/filters/about-formatting.sh\n\
readme=:README.rst\n\
readme=:readme.rst\n\
readme=:README.md\n\
readme=:readme.md\n\
readme=:README\n\
readme=:readme\n\
' >> /etc/cgitrc.default

FROM with-fmt AS with-highlighting
RUN apk add --no-cache highlight
ADD image/syntax-highlighting.sh /usr/lib/cgit/filters/syntax-highlighting-uwu.sh
RUN chmod +x /usr/lib/cgit/filters/syntax-highlighting-uwu.sh
RUN echo 'source-filter=/usr/lib/cgit/filters/syntax-highlighting-uwu.sh' >> /etc/cgitrc.default
