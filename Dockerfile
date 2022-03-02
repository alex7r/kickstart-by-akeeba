FROM mysql:latest

RUN apt-get update && \
    apt-get install unzip -y

ADD kick.sh /kick.sh

CMD ["/bin/sh", "/kick.sh"]
