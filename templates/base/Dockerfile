FROM --platform=${TARGETPLATFORM} ubuntu:jammy AS ubuntu-jammy

RUN apt-get update && \
	apt-get install --no-install-recommends --yes bash ca-certificates curl less libcurl4 libldap-2.4 libnss3 libpcre2-8-0 libssl3 telnet smartmontools tini tree tzdata unzip vim

RUN curl -H 'accept: */*' -L -s -X 'GET' -o /tmp/zabbix-release_6.2-1%2Bubuntu22.04_all.deb https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-1%2Bubuntu22.04_all.deb && \
dpkg -i /tmp/zabbix-release_6.2-1%2Bubuntu22.04_all.deb && \
rm -rf /tmp/zabbix-release_6.2-1%2Bubuntu22.04_all.deb && \
apt update && \
apt-get upgrade --yes  && \
apt install zabbix-agent2  && \
apt-get clean

RUN adduser --disabled-password --home /home/liferay liferay --uid 1000 && \
	addgroup liferay liferay && \
	usermod -g 1000 liferay

RUN mkdir -p /etc/zabbix && \
    mkdir -p /etc/zabbix/zabbix_agentd.d && \
    mkdir -p /var/lib/zabbix && \
		mkdir -p /var/run/zabbix && \
    mkdir -p /var/lib/zabbix/enc && \
    mkdir -p /var/lib/zabbix/modules && \
    mkdir -p /var/lib/zabbix/buffer && \
		mkdir -p /var/log/zabbix/ && \
		touch /var/log/zabbix/zabbix_agent2.log && \
    chown --quiet -R liferay:liferay /etc/zabbix/ /var/lib/zabbix/ /var/run/zabbix/ && \
    chgrp -R 0 /etc/zabbix/ /var/lib/zabbix/ /var/run/zabbix/ && \
    chmod -R g=u /etc/zabbix/ /var/lib/zabbix/ /var/run/zabbix/

COPY --chown=liferay:liferay resources/etc/zabbix/zabbix_agent2.conf /etc/zabbix/zabbix_agent2.conf
COPY resources/usr/local/bin/* /usr/local/bin/

FROM ubuntu-jammy

ARG LABEL_BUILD_DATE
ARG LABEL_NAME
ARG LABEL_VCS_REF
ARG LABEL_VCS_URL
ARG LABEL_VERSION
ARG TARGETPLATFORM

LABEL org.label-schema.build-date="${LABEL_BUILD_DATE}"
LABEL org.label-schema.name="${LABEL_NAME}"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.vcs-ref="${LABEL_VCS_REF}"
LABEL org.label-schema.vcs-url="${LABEL_VCS_URL}"
LABEL org.label-schema.vendor="Liferay, Inc."
LABEL org.label-schema.version="${LABEL_VERSION}"

EXPOSE 10050/TCP
EXPOSE 10051/TCP

ENTRYPOINT ["tini", "--", "/usr/local/bin/start_zabbix_agent.sh", "wait"]