#! /bin/bash

sudo docker build --rm -t chih7/dns:v1 .
sudo docker run -it -p 53:53/udp -p 753:753 -p 753:753/udp -p 853:853 -p 8853:8853 chih7/dns:v1

