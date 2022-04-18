FROM ubuntu:18.04
MAINTAINER Primiano Tucci <p.tucci@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g'  /etc/apt/sources.list \
    && apt-get -y update \
    && apt-get -y install git python-pip python-libvirt python-libxml2 supervisor novnc websockify \
    && apt-get -ys clean

RUN git clone https://github.com/retspen/webvirtmgr /webvirtmgr
WORKDIR /webvirtmgr
RUN git checkout 64528fa4098ef2c335be9ca649e2dd2637898202 #v4.8.9
RUN pip install -r requirements.txt

ADD local_settings.py /webvirtmgr/webvirtmgr/local/local_settings.py
RUN /usr/bin/python /webvirtmgr/manage.py collectstatic --noinput

ADD supervisor.webvirtmgr.conf /etc/supervisor/conf.d/webvirtmgr.conf
ADD gunicorn.conf.py /webvirtmgr/conf/gunicorn.conf.py
ADD bootstrap.sh /webvirtmgr/bootstrap.sh

RUN groupadd -g 1010 libvirtd
RUN useradd webvirtmgr -g libvirtd -u 1010 -d /data/vm -s /sbin/nologin
RUN chown webvirtmgr:libvirtd -R /webvirtmgr

WORKDIR /
VOLUME /data/vm

EXPOSE 8080
EXPOSE 6080
CMD ["supervisord", "-n"]
