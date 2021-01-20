# This a temporary workaround until libdns is fixed to work with DO
FROM caddy:2.3.0-builder AS builder

# See https://github.com/libdns/digitalocean/pull/3
RUN mkdir -p /root/go/src/github.com
RUN git clone https://github.com/delthas/digitalocean /root/go/src/github.com/digitalocean
RUN cd /root/go/src/github.com/digitalocean && git checkout fix-record-name

RUN xcaddy build \
	--with github.com/lucaslorentz/caddy-docker-proxy/plugin/v2 \
	# use the fixed branch for digitalocean - not the official
	--with github.com/libdns/digitalocean=/root/go/src/github.com/digitalocean \
	--with github.com/caddy-dns/digitalocean

# Pretty much taken straight from github.com/lucaslorentz/caddy-docker-proxy/plugin/v2
FROM caddy:2.3.0
COPY --from=builder /usr/bin/caddy /bin/caddy

EXPOSE 80 443 2019
ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

WORKDIR /

ENTRYPOINT ["/bin/caddy"]

CMD ["docker-proxy"]
