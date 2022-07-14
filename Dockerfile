FROM alpine:edge

ENV DNSSEC="1"
ENV DOT="1"

RUN apk add --no-cache unbound curl ca-certificates s6 \
  && echo "1" \
  && mkdir -p /var/lib/unbound \
  && mkdir -p /opt/unbound \
  && echo "2" \
  && curl -Ls -o /root.hints https://www.internic.net/domain/named.cache \
  && curl -Ls -o /var/lib/unbound/icannbundle.pem https://data.iana.org/root-anchors/icannbundle.pem \
  && echo "3" \
  && chmod 444 /root.hints \
  && echo "4" \
  && chown unbound:unbound /var/lib/unbound -R \
  && echo "5" \
  && chown unbound:unbound /opt/unbound -R \
  && echo "6" \
  && unbound-anchor -r /root.hints -a /var/lib/unbound/trusted-key.key -c /var/lib/unbound/icannbundle.pem \
  && echo "7"

COPY root/ /

RUN ls -la / && chmod a+x /service/*/run

EXPOSE 53/udp 53/tcp

ENTRYPOINT ["/bin/s6-svscan","/service"]