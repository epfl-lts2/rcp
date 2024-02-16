# Getting base ubuntu image with platform specified (important if you build on Apple Silicon)

FROM --platform=linux/amd64 ubuntu:focal

# Installing ssh, rsync, rclone, anaconda, vscode-server
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y openssh-server sudo rsync rclone zsh git curl vim tmux
RUN wget -O- https://aka.ms/install-vscode-server/setup.sh | sh

# Build arguments, for 'LDAP_' argument you can find information in your people.epfl.ch page
# admnistrative section, for SSH we recommend using public key instead of password, since it
# is visible in layers description after building

ARG LDAP_USERNAME
ARG LDAP_UID
ARG LDAP_GROUPNAME
ARG LDAP_GID
ARG SSH_PUBLIC_KEY

# Adding user and configuring SSH

RUN echo "${LDAP_USERNAME}  ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/sshd
RUN mkdir /var/run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN groupadd ${LDAP_GROUPNAME} --gid ${LDAP_GID}
RUN useradd -m -U -s /bin/zsh -G ${LDAP_GROUPNAME} -u ${LDAP_UID} ${LDAP_USERNAME}
RUN mkdir -p /home/${LDAP_USERNAME}/.ssh
RUN touch /home/${LDAP_USERNAME}/.ssh/authorized_keys
RUN echo ${SSH_PUBLIC_KEY} > /home/${LDAP_USERNAME}/.ssh/authorized_keys
RUN chown ${LDAP_USERNAME}:${LDAP_GROUPNAME} /home/${LDAP_USERNAME}/


RUN mkdir /opt/ssh
RUN ssh-keygen -q -N "" -t dsa -f /opt/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -b 4096 -f /opt/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t ecdsa -f /opt/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -q -N "" -t ed25519 -f /opt/ssh/ssh_host_ed25519_key
RUN cp /etc/ssh/sshd_config /opt/ssh/
RUN cat <<EOT >> /opt/ssh/sshd_config
Port 2022
HostKey /opt/ssh/ssh_host_rsa_key
HostKey /opt/ssh/ssh_host_ecdsa_key
HostKey /opt/ssh/ssh_host_ed25519_key
LogLevel INFO
ChallengeResponseAuthentication no
PidFile /opt/ssh/sshd.pid
EOT
RUN chmod 600 /opt/ssh/*
RUN chmod 644 /opt/ssh/sshd_config
RUN chown -R ${LDAP_USERNAME}:${LDAP_GROUPNAME} /opt/ssh/
RUN chown ${LDAP_USERNAME}:${LDAP_GROUPNAME} /etc/systemd/system/sshd.service

EXPOSE 2022

# Configuring Anaconda

USER ${LDAP_USERNAME}
WORKDIR /home/${LDAP_USERNAME}
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && bash /tmp/miniconda.sh -b -p $HOME/miniconda
SHELL ["/bin/zsh", "--login", "-c"]
ENV PATH /home/${LDAP_USERNAME}/miniconda/bin:${PATH}

COPY environment.yml .
RUN conda env create -f environment.yml
RUN conda init zsh


CMD ["/usr/sbin/sshd", "-D", "-f", "/opt/ssh/sshd_config", "-E", "/tmp/sshd.log"]
