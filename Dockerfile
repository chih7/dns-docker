FROM base/archlinux:latest
MAINTAINER Carson Chih <i@chih.me>

# add archlinuxcn repository
RUN echo "[archlinuxcn]\nServer = https://cdn.repo.archlinuxcn.org/$arch" >> /etc/pacman.conf && \
    pacman -Syy && sudo pacman -S archlinuxcn-keyring

# Base installation
RUN pacman -Syyu --noconfirm --noprogressbar && \
    pacman -S --noconfirm --needed --noprogressbar \
    git \
    unbound \
    dns-over-https-client \
    dns-over-https-server \
    nginx


# dnsmasq-china-list
RUN git clone --depth 1 https://github.com/felixonmars/dnsmasq-china-list.git && \
    cd ./dnsmasq-china-list && \
    make unbound && \
    mkdir -p /etc/unbound/china && \
    cp *.unbound.conf /etc/unbound/china/


# Config 
COPY resources/doh-client.conf /etc/dns-over-https/
COPY resources/unbound.conf /etc/unbound/
COPY resources/nginx.conf /etc/nginx/
COPY resources/cert/chih.me/privkey.pem //etc/letsencrypt/live/chih.me/
COPY resources/cert/chih.me/cert.pem /etc/letsencrypt/live/chih.me/

# enable and start systemd service
RUN systemctl enable --now  doh-client.service unbound.service ngnix.service

EXPOSE 53/udp
EXPOSE 753/udp
EXPOSE 753/tcp
EXPOSE 853/tcp
EXPOSE 8853/tcp
