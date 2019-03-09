FROM docker-repo:8081/docker-framework:latest

MAINTAINER Nabarun Sen nabarun.sen@gmail.com

RUN rm -rf /home/exec/apache-tomcat-8.5.38/webapps/*

ADD war/*.war /home/exec/apache-tomcat-8.5.38/webapps/ROOT.war
CMD /bin/bash -c cd /home/exec; /home/exec/apache-tomcat-8.5.38/bin/catalina.sh run
