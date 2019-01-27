FROM base/archlinux:latest
LABEL maintainer="Carson Chih <i@chih.me>"

# add archlinuxcn repository
RUN echo -e "[archlinuxcn]\nServer = https://cdn.repo.archlinuxcn.org/\$arch" >> /etc/pacman.conf && \
    echo "Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist && \
    # cat /etc/pacman.conf && \
    # cat /etc/pacman.d/mirrorlist && \
    pacman -Syyu --noconfirm --noprogressbar && \
    pacman -S --noconfirm --needed --noprogressbar \
    archlinuxcn-keyring && \
    pacman -S --noconfirm --needed --noprogressbar \
    git \
    unbound \
    dns-over-https-client \
    dns-over-https-server \
    nginx \
    dnsmasq-china-list-git

# dnsmasq-china-list
RUN mkdir -p /etc/unbound/china && \
	cut -d "/" -f 2 /etc/dnsmasq.d/accelerated-domains.china.conf | sed -e 's|\(.*\)|forward-zone:\n  name: "\1."\n  forward-addr: 114.114.114.114\n|' > /etc/unbound/china/accelerated-domains.china.unbound.conf && \
	cut -d "/" -f 2 /etc/dnsmasq.d/google.china.conf | sed -e 's|\(.*\)|forward-zone:\n  name: "\1."\n  forward-addr: 114.114.114.114\n|' > /etc/unbound/china/google.china.unbound.conf && \
	cut -d "/" -f 2 /etc/dnsmasq.d/apple.china.conf | sed -e 's|\(.*\)|forward-zone:\n  name: "\1."\n  forward-addr: 114.114.114.114\n|' > /etc/unbound/china/apple.china.unbound.conf

# Config 
COPY resources/doh-client.conf /etc/dns-over-https/
COPY resources/unbound.conf /etc/unbound/
COPY resources/nginx.conf /etc/nginx/
COPY resources/cert/chih.me/privkey.pem /etc/letsencrypt/live/chih.me/
COPY resources/cert/chih.me/fullchain.pem /etc/letsencrypt/live/chih.me/

# enable and start systemd service
RUN systemctl enable --now doh-client.service doh-server.service unbound.service nginx.service

EXPOSE 53/udp
EXPOSE 753/udp
EXPOSE 753/tcp
EXPOSE 853/tcp
EXPOSE 8853/tcp
