FROM alpine:edge

ENV DNSSEC="1"
ENV DOT="1"

RUN apk add --no-cache unbound curl ca-certificates s6 \
  && mkdir -p /var/lib/unbound \
  && mkdir -p /opt/unbound \
  && curl -Ls -o /root.hints https://www.internic.net/domain/named.cache \
  && curl -Ls -o /var/lib/unbound/icannbundle.pem https://data.iana.org/root-anchors/icannbundle.pem \
  && chmod 444 /root.hints \
  && chown unbound:unbound /var/lib/unbound -R \
  && chown unbound:unbound /opt/unbound -R \
  && unbound-anchor -4 -r /root.hints -a /var/lib/unbound/trusted-key.key -c /var/lib/unbound/icannbundle.pem

COPY root/ /

RUN ls -la / && chmod a+x /service/*/run

EXPOSE 53/udp 53/tcp

ENTRYPOINT ["/bin/s6-svscan","/service"]