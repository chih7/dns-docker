#! /bin/bash

sudo docker build --rm -t chih7/dns-docker:v0.1 .

sudo docker run -d --restart=always --name=dns-docker \
    -v /home/chih/chih.me/privkey.pem:/etc/letsencrypt/live/chih.me/privkey.pem \
    -v /home/chih/chih.me/fullchain.pem:/etc/letsencrypt/live/chih.me/fullchain.pem \
    -v /home/chih/chih.me/chain.pem:/etc/letsencrypt/live/chih.me/chain.pem \
    -v /home/chih/dhparams.pem:/etc/ssl/certs/dhparams.pem \
    -p 753:753 \
    -p 853:853 \
    -p 753:753/udp \
    -p 8853:8853 \
    chih7/dns-docker