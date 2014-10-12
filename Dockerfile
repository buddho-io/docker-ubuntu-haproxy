#
# HAProxy Dockerfile
#
# http://github.com/buddho-io/docker-ubuntu-haproxy

FROM ubuntu:14.04
MAINTAINER lance@buddho.io

ENV DEBIAN_FRONTEND noninteractive

# Update the system
RUN apt-get update && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# Add APT backports and install HAProxy
RUN \
  sed -i 's/^# \(.*-backports\s\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y haproxy=1.5.3-1~ubuntu14.04.1 && \
  sed -i 's/^ENABLED=.*/ENABLED=1/' /etc/default/haproxy && \
  rm -rf /var/lib/apt/lists/*

# Add files.
ADD haproxy.cfg /etc/haproxy/haproxy.cfg
ADD start.sh /usr/sbin/start

# Define mountable directories.
VOLUME /config/haproxy

# Define working directory.
WORKDIR /etc/haproxy

# Define default command.
CMD start

# Expose ports.
EXPOSE 80
EXPOSE 443
