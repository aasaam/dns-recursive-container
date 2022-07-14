#!/usr/bin/env sh

set -e

if [ $DNSSEC == "1" ]; then
  echo "Running with DNSSEC"
  cp /etc/unbound-config/unbound.DNSSEC.conf /etc/unbound/unbound.conf
else 
  echo "Running WITHOUT DNSSEC"
  cp /etc/unbound-config/unbound.conf /etc/unbound/unbound.conf
fi

if [ -f /forwarders.conf ]; then
  echo "Custom forward-zone"
  cp /forwarders.conf /opt/unbound/forwarders.conf
else
  if [ $DOT == "1" ]; then
    echo "Default forward-zone with DOT"
    cp /etc/unbound-config/forwarders.DOT.conf /opt/unbound/forwarders.conf
  else 
    echo "Default forward-zone WITHOUT DOT"
    cp /etc/unbound-config/forwarders.conf /opt/unbound/forwarders.conf
  fi
fi

chown unbound:unbound /opt/unbound -R

unbound-anchor -v -r /root.hints -a /var/lib/unbound/trusted-key.key -c /var/lib/unbound/icannbundle.pem || true

/usr/sbin/unbound -d -p -c /etc/unbound/unbound.conf