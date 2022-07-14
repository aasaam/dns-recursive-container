#!/usr/bin/env sh

set -e

if [ $STRICT_MODE == "1" ]; then
  echo "Enable DNSSEC and DOT"
  cp /etc/unbound-config/unbound.DNSSEC.conf /etc/unbound/unbound.conf
  cp /etc/unbound-config/forwarders.DOT.conf /opt/unbound/forwarders.conf
else
  echo "Disable DNSSEC and DOT"
  cp /etc/unbound-config/unbound.conf /etc/unbound/unbound.conf
  cp /etc/unbound-config/forwarders.conf /opt/unbound/forwarders.conf
fi

# forwarders
if [ -f /forwarders.conf ]; then
  echo "Custom forward-zone"
  cp /forwarders.conf /opt/unbound/forwarders.conf
fi

# access
cp /etc/unbound-config/access.conf /opt/unbound/access.conf
if [ -f /access.conf ]; then
  echo "Custom access-control"
  cp /access.conf /opt/unbound/access.conf
fi

if [ $STRICT_MODE == "1" ]; then
  echo "Update trusted-key for DNSSEC"
  unbound-anchor -v -r /root.hints -a /var/lib/unbound/trusted-key.key -c /var/lib/unbound/icannbundle.pem || true
fi

chown unbound:unbound /opt/unbound -R

/usr/sbin/unbound -d -p -c /etc/unbound/unbound.conf
