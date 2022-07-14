FROM alpine:edge

# STRICT_MODE will be enable DNSSEC with DOT
ENV STRICT_MODE="1"

COPY entrypoint.sh /entrypoint.sh

RUN apk add --no-cache unbound curl ca-certificates \
  && mkdir -p /var/lib/unbound \
  && mkdir -p /opt/unbound \
  && curl -Ls -o /root.hints https://www.internic.net/domain/named.cache \
  && curl -Ls -o /var/lib/unbound/icannbundle.pem https://data.iana.org/root-anchors/icannbundle.pem \
  && chmod 444 /root.hints \
  && chown unbound:unbound /var/lib/unbound -R \
  && chown unbound:unbound /opt/unbound -R \
  && unbound-anchor -v -r /root.hints -a /var/lib/unbound/trusted-key.key -c /var/lib/unbound/icannbundle.pem || true \
  && unbound -V \
  && chmod +x /entrypoint.sh

COPY root/ /

EXPOSE 53/udp 53/tcp

ENTRYPOINT ["/entrypoint.sh"]
