FROM ubuntu:20.04
LABEL Author="Suvaj S Parathanam" \
Co-Author="Archana Gopi" \
Application="Robot Framework" \
Description="Docker Configurations for JTA"

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN=true

ENV TZ "Asia/Kolkata"

RUN set -ex; \ 
apt-get update && apt-get upgrade -y; \
# apt install -y --no-install-recommends ;\
apt-get install -y \
apt-utils \
# python3 \
python3-pip \
build-essential \
libssl-dev \
libcurl4-openssl-dev \
python3-dev \
default-libmysqlclient-dev \
# python-requests \
openssh-client \
sshpass \
python3-setuptools \
mysql-client \
redis-tools \
curl \
pkg-config \
&& echo "tzdata tzdata/Areas select Asia" > /tmp/preseed.txt; \
echo "tzdata tzdata/Zones/Asia select Kolkata" >> /tmp/preseed.txt; \
debconf-set-selections /tmp/preseed.txt \
&& apt install -y tzdata \
&& ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
&& apt autoremove \
&& apt clean \
&& rm -r /var/lib/apt/lists/* \
&& python3 -m pip install pip setuptools \
setuptools-rust \
robotframework \
requests \
robotframework-requests \
# pymysql \
mysqlclient \
robotframework-faker \
robotframework-pabot \
# pycurl \
openpyxl \
phonenumbers \
robotframework-jsonlibrary \ 
# timezonefinder \
cryptography \
&& mkdir -p /ebs/TDD /ebs/TDD_Output /ebs/TDD_Output/signuplog /ebs/TDD_Output/tddreport /ebs/ynwconf /home/user/.ssh/ \
&& useradd -lm -u ${USER_ID} user \
&& chown --changes --silent --no-dereference --recursive \
        ${USER_ID}:${GROUP_ID} \
        /ebs \
        /home/user

VOLUME /ebs/ /ebs/TDD /ebs/conf
WORKDIR /ebs

USER user  

#RUN chmod a+x /ebs/conf/runrobot.sh

# CMD ["chmod", "a+x", "/ebs/conf/runrobot.sh", ";", "sh", "-c", "/ebs/conf/runrobot.sh"]
# CMD ["/bin/bash", "-c", "chmod a+x /ebs/conf/runrobot.sh; /ebs/conf/runrobot.sh"]
CMD ["/bin/bash", "-c", "/ebs/conf/runrobot.sh"]
