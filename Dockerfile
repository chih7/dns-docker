FROM base/archlinux:latest
LABEL maintainer="Carson Chih <i@chih.me>"

ARG MIRROR_URL="https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch"
ARG MIRROR_CN_URL="https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch"
# add archlinuxcn repository
RUN echo -e "[archlinuxcn]\nServer = ${MIRROR_CN_URL}" >> /etc/pacman.conf && \
    echo "Server = ${MIRROR_URL}" > /etc/pacman.d/mirrorlist && \
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
    dnsmasq-china-list-git \
    supervisor \
    dnsmasq

# Config 
COPY resources/doh-client.conf /etc/dns-over-https/
COPY resources/doh-server.conf /etc/dns-over-https/
COPY resources/unbound.conf /etc/unbound/
COPY resources/dnsmasq.conf /etc/
COPY resources/nginx.conf /etc/nginx/
COPY resources/cert/chih.me/privkey.pem /etc/letsencrypt/live/chih.me/
COPY resources/cert/chih.me/fullchain.pem /etc/letsencrypt/live/chih.me/
COPY resources/cert/chih.me/dhparams.pem /etc/ssl/certs/
COPY resources/supervisord.conf /etc/
# copy directory
COPY resources/supervisor.d /etc/supervisor.d

EXPOSE 53/udp
EXPOSE 753/udp
EXPOSE 753/tcp
EXPOSE 853/tcp
EXPOSE 8853/tcp

# ENTRYPOINT [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
CMD [ "/usr/bin/dnsmasq", "-k", "--user=dnsmasq", "--pid-file" ]
