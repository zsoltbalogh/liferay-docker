FROM azul/zulu-openjdk:8u302

ARG LABEL_BUILD_DATE
ARG LABEL_NAME
ARG LABEL_VCS_REF
ARG LABEL_VCS_URL
ARG LABEL_VERSION

COPY --chown=root:root repositories/jammy.list /etc/apt/sources.list.d/jammy.list

RUN apt-get update && \
	apt-get install -t focal -y bash curl ghostscript gifsicle imagemagick jattach libnss3 libtcnative-1 telnet tree ttf-dejavu unzip zulu11-jdk=11.0.13-1 && \
	apt-get install -t jammy -y ffmpeg && \
	apt-get upgrade -y && \
	apt-get clean

COPY scripts/* /usr/local/bin/

RUN adduser --disabled-password --home /home/liferay liferay --uid 1000 && \
	addgroup liferay liferay && \
	usermod -g 1000 liferay

COPY --chown=liferay:liferay home/.bashrc /home/liferay/

ENV JAVA_VERSION=zulu8

LABEL org.label-schema.build-date="${LABEL_BUILD_DATE}"
LABEL org.label-schema.name="${LABEL_NAME}"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.vcs-ref="${LABEL_VCS_REF}"
LABEL org.label-schema.vcs-url="${LABEL_VCS_URL}"
LABEL org.label-schema.vendor="Liferay, Inc."
LABEL org.label-schema.version="${LABEL_VERSION}"