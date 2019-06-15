FROM sebp/elk

MAINTAINER Hasim github.com/hasimabanoz
ENV \
 REFRESHED_AT=2019-06-14
WORKDIR /opt

# create directories
RUN mkdir /opt/tomcat &&\
    mkdir /opt/logs &&\
    mkdir /opt/kafka

# --------- #
# --Kafka-- #
# --------- #
COPY kafka_2.12-2.2.1.tgz /opt/

RUN tar -C /opt/kafka/ -xf /opt/kafka_2.12-2.2.1.tgz

RUN rm -f /opt/kafka_2.12-2.2.1.tgz &&\
    chmod -R 777 /opt/kafka/ &&\
    chmod -R 777 /opt/logs/

# ---------- #
# --Tomcat-- #
# ---------- #
COPY apache-tomcat-8.5.42.tar.gz /opt/

RUN tar -C /opt/tomcat/ -xf /opt/apache-tomcat-8.5.42.tar.gz

# war dosyalarını tomcat altına kopyala
COPY log-* /opt/tomcat/apache-tomcat-8.5.42/webapps/

RUN rm -f /opt/apache-tomcat-8.5.42.tar.gz &&\
    chmod -R 777 /opt/tomcat/

# ------------ #
# --Logstash-- #
# ------------ #
# overwrite logstash pipeline
ADD pipelines.yml ${LOGSTASH_PATH_SETTINGS}/pipelines.yml

# add kafka conf
ADD logstash-kafka-consumer.conf /etc/logstash/conf.d/logstash-kafka-consumer.conf
ADD logstash-kafka-producer.conf /etc/logstash/conf.d/logstash-kafka-producer.conf

# remove unused conf files
# bu conf dosyaları pipeline'a kullanılmadığı için silinmese de olur
RUN rm -f ${LOGSTASH_PATH_CONF}/conf.d/02-beats-input.conf &&\
    rm -f ${LOGSTASH_PATH_CONF}/conf.d/10-syslog.conf &&\
    rm -f ${LOGSTASH_PATH_CONF}/conf.d/11-nginx.conf &&\
    rm -f ${LOGSTASH_PATH_CONF}/conf.d/30-output.conf

ADD ./start_custom.sh /usr/local/bin/start_custom.sh
RUN chmod +x /usr/local/bin/start_custom.sh

CMD [ "/usr/local/bin/start_custom.sh" ]
