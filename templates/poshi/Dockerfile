FROM --platform=${TARGETPLATFORM} liferay/jdk11:latest AS liferay-jdk11

RUN curl https://downloads.gradle-dn.com/distributions/gradle-7.5-bin.zip --output /tmp/gradle.zip && \
	cd /usr/local/ && \
	unzip -q /tmp/gradle.zip && \
	ln -s /usr/local/gradle-*/bin/gradle /usr/local/bin/gradle