#!/bin/bash

apt-get update 
echo "net.ipv4.icmp_echo_ignore_all = 1" >> /etc/sysctl.conf
sysctl -p
apt-get install -y squid3 apache2-utils



echo '' > /etc/squid/squid.conf

cat <<EOF > /etc/squid/squid.conf
http_port 3128

visible_hostname squidworth

acl manager proto cache_object


refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .                 0     20%     4320

dns_nameservers 8.8.8.8 8.8.4.4
positive_dns_ttl 6 hours
negative_dns_ttl 1 minutes

auth_param basic program /usr/lib/squid/basic_ncsa_auth  /etc/squid/pass
auth_param basic children 5
auth_param basic realm ServerName
auth_param basic credentialsttl 24 hour


acl ncsa_users proxy_auth REQUIRED

acl localnet src 10.0.0.0/8     # RFC 1918 possible internal network
acl localnet src 172.16.0.0/12  # RFC 1918 possible internal network
acl localnet src 192.168.0.0/16 # RFC 1918 possible internal network
acl localnet src fc00::/7       # RFC 4193 local private network range
acl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines

acl SSL_ports port 443          # https
acl SSL_ports port 22           # ssh

acl Safe_ports port 80          # http
acl Safe_ports port 21          # ftp
acl Safe_ports port 22          # ssh
acl Safe_ports port 443         # https
acl Safe_ports port 70          # gopher
acl Safe_ports port 210         # wais
acl Safe_ports port 1025-65535  # unregistered ports
acl Safe_ports port 280         # http-mgmt
acl Safe_ports port 488         # gss-http
acl Safe_ports port 591         # filemaker
acl Safe_ports port 777         # multiling http

acl CONNECT method CONNECT

http_access allow ncsa_users
http_access allow Safe_ports
http_access allow CONNECT SSL_ports
http_access allow localnet
http_access deny all

request_header_access Allow allow all
request_header_access Authorization allow all
request_header_access WWW-Authenticate allow all
request_header_access Proxy-Authorization allow all
request_header_access Proxy-Authenticate allow all
request_header_access Cache-Control allow all
request_header_access Content-Encoding allow all
request_header_access Content-Length allow all
request_header_access Content-Type allow all
request_header_access Date allow all
request_header_access Expires allow all
request_header_access Host allow all
request_header_access If-Modified-Since allow all
request_header_access Last-Modified allow all
request_header_access Location allow all
request_header_access Pragma allow all
request_header_access Accept allow all
request_header_access Accept-Charset allow all
request_header_access Accept-Encoding allow all
request_header_access Accept-Language allow all
request_header_access Content-Language allow all
request_header_access Mime-Version allow all
request_header_access Retry-After allow all
request_header_access Title allow all
request_header_access Connection allow all
request_header_access Proxy-Connection allow all
request_header_access User-Agent allow all
request_header_access Cookie allow all
request_header_access All deny all

via off
forwarded_for off
follow_x_forwarded_for deny all

debug_options ALL,5

EOF

echo 'user1:$apr1$FZeV00GX$avazDffp6clww.2Y5Abn11' > /etc/squid/pass
chmod 775 /etc/squid/pass
/etc/init.d/squid start


