FROM maven:3-jdk-8-alpine as builder
ADD helloworld /app
WORKDIR /app
RUN mvn package && \
    mv -v target/*.war /helloworld.war


FROM openjdk:8-alpine
ADD jboss-eap-6.4.0.zip /jboss.zip
ENV EAP_HOME /jboss
RUN unzip /jboss.zip -d / && \
    rm -fv /jboss.zip && \
    mv -v /jboss-* /jboss
COPY --from=builder /helloworld.war /jboss/standalone/deployments/
ENTRYPOINT ["/jboss/bin/standalone.sh"]
