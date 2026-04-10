FROM stubby AS initial

FROM ubuntu:focal

ARG TARGETARCH
ARG P4RELEASE

COPY files/entrypoint.sh /

RUN /usr/bin/apt update && \
    /usr/bin/apt install -y openssl wget tar ca-certificates && \
    if [ "${TARGETARCH}" = "amd64" ]; then \
        /usr/bin/wget -O /tmp/p4.tgz \
            https://filehost.perforce.com/perforce/r${P4RELEASE}/bin.linux26x86_64/helix-core-server.tgz; \
    fi && \
    if [ "${TARGETARCH}" = "arm64" ]; then \
        /usr/bin/wget -O /tmp/p4.tgz \
        https://filehost.perforce.com/perforce/r${P4RELEASE}/bin.linux26aarch64/helix-core-server.tgz; \
    fi && \
    /usr/bin/mkdir -p /var/lib/p4 && \
    /usr/bin/tar -xvf /tmp/p4.tgz -C /var/lib/p4 && \
    /usr/bin/chmod a+x /var/lib/p4/p4d && \
    /usr/bin/ln -s /var/lib/p4/p4 /usr/bin/p4 && \
    echo -ne "P4_1666_CHARSET=none\nP4_ssl64:[::]:1666_CHARSET=none\n" > /var/lib/p4/p4enviro.sample.txt && \
    /usr/bin/rm -f /tmp/p4.tgz && \
    /usr/bin/rm -rf /var/lib/apt/lists/*

ENV P4CONFIG=.p4config
ENV P4ROOT="/opt/p4d"
ENV P4PORT="ssl64:[::]:1666"
ENV P4LOG="log"
ENV P4JOURNAL="journal"
ENV P4SSLDIR="/opt/p4d/ssl"

EXPOSE 1666/tcp

CMD ["/entrypoint.sh"]
