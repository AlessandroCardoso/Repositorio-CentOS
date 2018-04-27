FROM debian:9.2

RUN apt-get update
RUN apt-get install -y wget dos2unix nginx openssh-server createrepo
RUN apt-get install -y vim mlocate 
RUN apt-get clean

ENV ROOT_DIR=/etc/i9corp/packages
ENV CENTOS_DIR=${ROOT_DIR}/centos
ENV CENTOS_DISTRIB=${CENTOS_DIR}/5.11/x86_64

COPY ./tools/sync-repo /usr/local/bin/sync-repo
RUN dos2unix /usr/local/bin/sync-repo
RUN chmod +x /usr/local/bin/sync-repo

COPY ./tools/start-packages /usr/local/bin/start-packages
RUN dos2unix /usr/local/bin/start-packages
RUN chmod +x /usr/local/bin/start-packages

COPY ./nginx/centos /etc/nginx/sites-available/default

RUN mkdir -p ${CENTOS_DISTRIB}/base
RUN createrepo ${CENTOS_DISTRIB}/base

RUN mkdir -p ${CENTOS_DISTRIB}/updates
RUN createrepo ${CENTOS_DISTRIB}/updates

ARG REPO_PASSWD=123456

RUN useradd -ms /bin/bash repo && echo "repo:${REPO_PASSWD}" | chpasswd

RUN chown -R repo:repo ${ROOT_DIR}

VOLUME [ "/etc/i9corp/packages" ]

#Nginx
EXPOSE 80

#SSH
EXPOSE 22

#Proftpd
EXPOSE 21
EXPOSE 20

CMD ["/usr/local/bin/start-packages"]
