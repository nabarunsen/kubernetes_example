FROM docker-repo:8081/docker/ubuntu:latest

MAINTAINER Nabarun Sen nabarun.sen@gmail.com

RUN mkdir -p /home/exec/jdk /home/exec/tomcat

COPY jdk-8u201-linux-x64.tar /home/exec/
RUN cd /home/exec/ && tar -xvf /home/exec/jdk-8u201-linux-x64.tar
ENV JAVA_HOME=/home/exec/jdk1.8.0_201
#RUN sed "/securerandom.source=/{s/file:\/dev\/random/file:\/dev\/urandom/}" /home/exec/jdk8/jre/lib/security/java.security -i

COPY apache-tomcat-8.5.38.tar /home/exec/tomcat
RUN cd /home/exec/ && tar -xvf /home/exec/tomcat/apache-tomcat-8.5.38.tar
ADD tomcat/server.xml /home/exec/apache-tomcat-8.5.38/conf/server.xml
ENV CATALINA_HOME=/home/exec/apache-tomcat-8.5.38
ENV TEST_ENV=2

CMD /bin/bash -c cd /home/exec; /home/exec/apache-tomcat-8.5.38/bin/catalina.sh run
