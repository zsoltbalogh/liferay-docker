FROM --platform=${TARGETPLATFORM} liferay/jdk11:latest AS liferay-jdk11

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install --no-install-recommends --yes libatk-adaptor libatk1.0.0 libcups2 libdrm2 libgbm1 libglib2.0.0 libpango1.0 libxcomposite1 libxdamage1 libxfixes3 libxkbcommon0 libxrandr2 && \
	apt-get upgrade --yes && \
	apt-get clean

RUN curl https://downloads.gradle-dn.com/distributions/gradle-7.5-bin.zip --output /tmp/gradle.zip && \
	cd /usr/local/ && \
	unzip -q /tmp/gradle.zip && \
	ln -s /usr/local/gradle-*/bin/gradle /usr/local/bin/gradle

RUN curl https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F972765%2Fchrome-linux.zip?generation=1645149566184332\&alt=media --output /tmp/chrome.zip && \
	cd /usr/local && \
	unzip -q /tmp/chrome.zip