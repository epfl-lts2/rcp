# Getting base ubuntu image with platform specified (important if you build on Apple Silicon)

FROM --platform=linux/amd64 registry.rcp.epfl.ch/lts2-public/pytorch-base:latest

# Build arguments, for 'LDAP_' argument you can find information in your people.epfl.ch page
# admnistrative section, for SSH we recommend using public key instead of password, since it
# is visible in layers description after building

ARG LDAP_USERNAME
ARG LDAP_UID
ARG LDAP_GROUPNAME
ARG LDAP_GID

USER root
RUN echo "${LDAP_USERNAME}  ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/sshd

RUN usermod "--login=${LDAP_USERNAME}" "--home=/home/${LDAP_USERNAME}" \
        --move-home "-u ${LDAP_UID}" "${MAMBA_USER}" && \
    groupmod "--new-name=${LDAP_USERNAME}" \
        "-g ${LDAP_GID}" "${MAMBA_USER}" && \
    # Update the expected value of MAMBA_USER for the
    # _entrypoint.sh consistency check.
    echo "${LDAP_USERNAME}" > "/etc/arg_mamba_user" && \
    :
ENV MAMBA_USER=$LDAP_USERNAME
USER $MAMBA_USER