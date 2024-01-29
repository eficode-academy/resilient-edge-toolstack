FROM ghcr.io/eficode-academy/edgek8s-management

COPY upgrade_edge/upgrade_edge.sh /opt/upgrade_edge.sh

RUN chmod +x /opt/upgrade_edge.sh

CMD ["/bin/sh", "-x", "/opt/upgrade_edge.sh"]
