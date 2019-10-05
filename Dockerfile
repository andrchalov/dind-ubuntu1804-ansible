FROM ubuntu:18.04
LABEL maintainer="Andrey Chalov"

ENV pip_packages "ansible docker-py"

# Install dependencies.
RUN apt-get update
RUN apt-get install -y \
       apt-utils \
       locales \
       python-setuptools \
       python-pip \
       software-properties-common \
       rsyslog systemd systemd-cron sudo iproute2 \
       apt-transport-https ca-certificates curl iptables \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

# Install Docker from Docker Inc. repositories.
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce

RUN apt-get install -y rsync

# Fix potential UTF-8 errors with ansible-test.
RUN locale-gen en_US.UTF-8

# Install packages via Pip.
RUN pip install $pip_packages

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Install the magic wrapper.
COPY ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

ENTRYPOINT ["wrapdocker"]
