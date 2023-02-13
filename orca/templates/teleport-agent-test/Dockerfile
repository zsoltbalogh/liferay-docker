FROM ubuntu:jammy

RUN mkdir /run/sshd
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC \
        apt-get upgrade -y && \
        apt-get install --no-install-recommends -y openssh-server && \
	apt-get clean && \
	rm -fr /var/lib/apt/lists/*

RUN user=coyote && \
	adduser $user --gecos "LR COMMON Admin" --disabled-password && \
	install -d /home/$user/.ssh/ -o $user -g $user -m 0700 && \
	echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9cRilRehhA3bBKZfd8OITMFVyzQBUvCjvbejLsJavD tompos@private' > /home/$user/.ssh/authorized_keys && \
	chown -R $user:$user /home/$user/ && \
	chmod 600 /home/$user/.ssh/authorized_keys

RUN user=tomposmiko && \
	adduser $user --gecos "Tamas Papp" --disabled-password && \
	install -d /home/$user/.ssh/ -o $user -g $user -m 0700 && \
	echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9cRilRehhA3bBKZfd8OITMFVyzQBUvCjvbejLsJavD tompos@private' > /home/$user/.ssh/authorized_keys && \
	chown -R $user:$user /home/$user/ && \
	chmod 600 /home/$user/.ssh/authorized_keys

RUN echo -e "# teleport config" && \
	echo "HostKey /etc/ssh/teleport/teleport-agent-test.latest_default" >> /etc/ssh/sshd_config.d/teleport.conf && \
	echo "HostCertificate /etc/ssh/teleport/teleport-agent-test.latest_default-cert.pub" >> /etc/ssh/sshd_config.d/teleport.conf && \
	echo "TrustedUserCAKeys /etc/ssh/teleport/teleport_user_ca.pub" >> /etc/ssh/sshd_config.d/teleport.conf

CMD ["/usr/sbin/sshd","-D"]
