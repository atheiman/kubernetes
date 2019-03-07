FROM maven:3-jdk-8-alpine

ADD jboss-eap-6.4.0.zip /jboss.zip

RUN unzip /jboss.zip -d / && \
    rm -f /jboss.zip && \
    mv /jboss-* /jboss

ENV EAP_HOME /jboss

ENTRYPOINT ["/jboss/bin/standalone.sh"]
