FROM ghcr.io/eficode-academy/edgek8s-management

RUN apk add --no-cache bash

COPY upgrade_edge/upgrade_edge.sh /opt/upgrade_edge.sh

RUN chmod +x /opt/upgrade_edge.sh

CMD ["/bin/bash", "-x", "/opt/upgrade_edge.sh"]
