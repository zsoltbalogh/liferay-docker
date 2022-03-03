FROM azul/zulu-openjdk:11

ARG LABEL_BUILD_DATE
ARG LABEL_NAME
ARG LABEL_VCS_REF
ARG LABEL_VCS_URL
ARG LABEL_VERSION

RUN apt-get update && \
apt-get install -y bash curl ghostscript gifsicle imagemagick jattach libnss3 libtcnative-1 software-properties-common telnet tini tree ttf-dejavu unzip zulu8-jdk && \
	apt-get update && \
	add-apt-repository ppa:savoury1/ffmpeg4 && \
	apt-get install -y ffmpeg && \
	apt-get upgrade -t focal -y && \
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