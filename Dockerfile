FROM centos:centos7
MAINTAINER Prasad Gopale <prasadgopale@gmail.com>
# Install varioius utilities
RUN yum -y install curl wget unzip git vim mlocate \
iproute python-setuptools hostname inotify-tools yum-utils which \
epel-release openssh-server openssh-clients


# Configure SSH
RUN ssh-keygen -b 1024 -t rsa -f /etc/ssh/ssh_host_key \
&& ssh-keygen -b 1024 -t rsa -f /etc/ssh/ssh_host_rsa_key \
&& ssh-keygen -b 1024 -t dsa -f /etc/ssh/ssh_host_dsa_key \
&& sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
&& sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

# Set root password
RUN echo root:changeme | chpasswd && yum install -y passwd

#Setup Redis
RUN yum install epel-release -y && \
    yum update -y && \
    yum install redis -y && \
yum clean all


#Redis Configuration
RUN sed -ri 's/bind 127.0.0.1/#bind 127.0.0.1/g' /etc/redis.conf
RUN sed -ri 's/protected-mode yes/protected-mode no/g' /etc/redis.conf

RUN yum -y install nginx; yum clean all
#RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN echo "I Am Live :)" > /usr/share/nginx/html/index.html

# Install Python and Supervisor
RUN yum -y install python-setuptools \
&& mkdir -p /var/log/supervisor \
&& easy_install supervisor

COPY supervisord.conf /etc/supervisord.conf
#COPY nginx.conf /etc/nginx/nginx.conf


EXPOSE 22 80 443 6379
CMD ["/usr/bin/supervisord"]


