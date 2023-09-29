FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y wget gnupg python3-pip cron && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list && \
    apt-get update && apt-get install -y google-chrome-stable && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME /config

WORKDIR /app

COPY requirements.txt /app

RUN pip3 install -r requirements.txt

COPY glance-cron /etc/cron.d/glance-cron

RUN chmod 0644 /etc/cron.d/glance-cron && \
    crontab /etc/cron.d/glance-cron && \
    touch /var/log/cron.log

COPY *.py /app/

CMD set -a; . /config/.env; set a+; python3 /app/main.py; cron -f