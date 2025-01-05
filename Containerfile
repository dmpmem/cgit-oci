FROM docker.io/alpine:latest AS base

WORKDIR /root

# Funny lil packages
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
            libcap \
            lzip

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
CMD ["sh", "-c", "/usr/local/bin/prepare-container.sh && sh -c 'sleep 1 && chgrp www-data /run/fcgiwrap/fcgiwrap.sock && chmod g+w /run/fcgiwrap/fcgiwrap.sock && exec sudo -u http /usr/sbin/caddy run --config /etc/caddy/Caddyfile --adapter caddyfile' & /usr/local/bin/fcgiwrap-launcher"]

FROM base AS with-fmt
RUN apk add --no-cache py3-markdown py3-docutils groff
RUN echo -ne 'about-filter=/usr/lib/cgit/filters/about-formatting.sh\n' >> /etc/cgitrc.default

FROM with-fmt AS with-highlighting
RUN apk add --no-cache highlight
ADD image/syntax-highlighting.sh /usr/lib/cgit/filters/syntax-highlighting-uwu.sh
RUN chmod +x /usr/lib/cgit/filters/syntax-highlighting-uwu.sh
RUN echo -ne 'source-filter=/usr/lib/cgit/filters/syntax-highlighting-uwu.sh\n' >> /etc/cgitrc.default

FROM with-highlighting AS full
# with nice userland aswell
RUN apk add --no-cache curl zsh-fast-syntax-highlighting
RUN sed -i 's|/bin/ash|/bin/zsh|g' /etc/passwd
RUN (git clone https://git.estrogen.zone/zuwu.git/ /tmp/zuwu || git clone https://github.com/dmpmem/zuwu.git /tmp/zuwu) && \
    cd /tmp/zuwu && \
    ./install.zsh && \
    /usr/local/share/zsh/plugins/zuwu/setup.zsh && \
    sudo -u git /usr/local/share/zsh/plugins/zuwu/setup.zsh && \
    cd ~ && \
    rm -rf /tmp/zuwu && \
    mkdir -p /root/.local/bin && \
    mkdir /root/.zsh_history && \
    touch /root/.zsh_history/default

# TODO: impl. automated occasional updates
