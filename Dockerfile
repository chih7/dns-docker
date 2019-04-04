FROM archlinux/base:latest
LABEL maintainer="Carson Chih <i@chih.me>"

ARG MIRROR_CN_URL="https://cdn.repo.archlinuxcn.org/\$arch"
# add archlinuxcn repository
RUN echo -e "[archlinuxcn]\nServer = ${MIRROR_CN_URL}" >> /etc/pacman.conf && \
    pacman -Syy --noconfirm --noprogressbar && \
    pacman -S --noconfirm --needed --noprogressbar gettext grep make && \
    rm -rf /etc/pacman.d/gnupg && \
    pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman -S --noconfirm --needed --noprogressbar \
    archlinuxcn-keyring && \
    pacman -S --noconfirm --needed --noprogressbar \
    git \
    dns-over-https-client \
    dns-over-https-server \
    nginx-mainline \
    dnsmasq-china-list-git \
    supervisor \
    dnsmasq \
    unbound

# dnsmasq-china-list
RUN git clone --depth 1 https://github.com/felixonmars/dnsmasq-china-list.git && \
    cd ./dnsmasq-china-list && \
    make SERVER=223.5.5.5 unbound && \
    mkdir -p /etc/unbound/china && \
    cp *.unbound.conf /etc/unbound/china/

RUN mkdir -p /etc/letsencrypt/live/chih.me/ && \
    mkdir -p /etc/ssl/certs/ && \
    mkdir -p /etc/hosts.d/

ADD https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts /etc/hosts.d/StevenBlack_hosts
ADD https://www.internic.net/domain/named.cache /etc/unbound/root.hints

# Config 
COPY resources/doh-client.conf /etc/dns-over-https/
COPY resources/doh-server.conf /etc/dns-over-https/
COPY resources/dnsmasq.conf /etc/
COPY resources/unbound.conf /etc/unbound/
COPY resources/nginx.conf /etc/nginx/
COPY resources/tls.conf /etc/nginx/
COPY resources/supervisord.conf /etc/
# copy directory
COPY resources/supervisor.d /etc/supervisor.d

EXPOSE 753/udp
EXPOSE 753/tcp
EXPOSE 853/tcp
EXPOSE 8853/tcp

ENTRYPOINT [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]