FROM debian:buster
ARG VERSION=latest
MAINTAINER Tristan Teufel <info@teufel-it.de> / Gerald Brunner

LABEL update="2021-06-30"

RUN apt-get update
RUN apt-get install sqlite3 libcrypto++6 libcurl4 libfuse2 wget btrfs-tools -y

RUN if [ "${VERSION}" = "latest" ] ; then \
    LATEST=$(wget https://hndl.urbackup.org/Server/latest/debian/buster/ -q -O - | tr '\n' '\r' | sed -r 's/.*server_([0-9\.]+)_amd64\.deb.*/\1/') && \
    wget -O /root/urbackup.deb https://hndl.urbackup.org/Server/latest/debian/buster/urbackup-server_${LATEST}_amd64.deb; \
    else wget -O /root/urbackup.deb https://www.urbackup.org/downloads/Server/${VERSION}/debian/buster/urbackup-server_${VERSION}_amd64.deb; \
    fi

RUN DEBIAN_FRONTEND=noninteractive dpkg -i /root/urbackup.deb  || true

ADD backupfolder /etc/urbackup/backupfolder
RUN chmod +x /etc/urbackup/backupfolder

EXPOSE 55413
EXPOSE 55414
EXPOSE 55415
EXPOSE 35623

HEALTHCHECK  --interval=5m --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost:55414/ || exit 1

VOLUME [ "/var/urbackup", "/var/log", "/backup"]
ENTRYPOINT ["/usr/bin/urbackupsrv"]
CMD ["run"]

