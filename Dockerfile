FROM ruby:2.3.1-alpine
MAINTAINER hmt <dev@hmt.im>

ENV DEV_PACKAGES="mariadb-dev git build-base postgresql-dev openssl-dev" \
    FF_PACKAGES="xvfb cups firefox openrc" \
    SLIMERPATH="/usr/src/app/slimerjs" \
    SLIMERJSLAUNCHER="/usr/bin/firefox"

RUN apk add --no-cache $DEV_PACKAGES $FF_PACKAGES
# Tell openrc its running inside a container, till now that has meant LXC
RUN sed -i 's/#rc_sys=""/rc_sys="lxc"/g' /etc/rc.conf &&\
# Tell openrc loopback and net are already there, since docker handles the networking
    echo 'rc_provide="loopback net"' >> /etc/rc.conf &&\
# no need for loggers
    sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf &&\
# can't get ttys unless you run the container in privileged mode
    sed -i '/tty/d' /etc/inittab &&\
# can't set hostname since docker sets it
    sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname &&\
# can't mount tmpfs since not privileged
    sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh &&\
# can't do cgroups
    sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh

COPY init_sahib.init /etc/init.d/sahib
RUN mkdir -p /usr/src/app/sahib && \
    chmod +x /etc/init.d/sahib && \
    rc-update add cupsd && \
    rc-update add sahib && \
    wget https://download.slimerjs.org/releases/0.10.0/slimerjs-0.10.0.zip && \
    unzip slimerjs-0.10.0.zip && \
    mv slimerjs-0.10.0 /usr/src/app/slimerjs && \
    rm slimerjs*.zip

WORKDIR /usr/src/app/sahib
CMD ["/sbin/init"]

COPY Gemfile /usr/src/app/sahib
COPY Gemfile.lock /usr/src/app/sahib
RUN bundle install

COPY . /usr/src/app/sahib

