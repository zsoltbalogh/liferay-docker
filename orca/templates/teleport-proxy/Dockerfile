FROM public.ecr.aws/gravitational/teleport:12

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get upgrade --yes && \
	apt-get clean && \
	rm -fr /var/lib/apt/lists/*

COPY resources/etc/teleport/teleport.yaml /etc/teleport/
COPY resources/root/ /root/
#ENTRYPOINT ["tini", "--", "/usr/local/bin/teleport_server_entrypoint.sh"]
