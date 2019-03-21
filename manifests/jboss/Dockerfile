FROM maven:3-jdk-8-alpine as builder
ADD helloworld /app
WORKDIR /app
RUN mvn package && \
    mv -v target/*.war /helloworld.war


FROM centos:6

ADD jboss-eap-6.4.0.zip /jboss.zip
RUN yum update -y && \
    yum install -y unzip java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
    unzip /jboss.zip -d / && \
    rm -fv /jboss.zip && \
    mv -v /jboss-* /jboss && \
    groupadd --gid 999 jboss && \
    useradd --system --uid 999 --gid jboss --home-dir /jboss jboss && \
    chown --recursive jboss:jboss /jboss && \
    yum clean all

USER jboss
COPY --from=builder --chown=jboss:jboss /helloworld.war /jboss/standalone/deployments/

## To make the JVM respect memory limits on the container, either specify start and max heap:
# -Xms256m -Xmx512m
## Or make the JVM container aware (see https://banzaicloud.com/blog/java-resource-limits/):
# -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:MaxRAMFraction=1 -Xms64M

## Runs process inside a shell so it does not respond to signals
# ENTRYPOINT ["/jboss/bin/standalone.sh", "-b", "0.0.0.0"]

## Full default standalone.sh java process spawned by standalone.sh
# ENTRYPOINT ["java", "-D[Standalone]", "-server", "-Xms1303m", "-Xmx1303m", "-XX:MaxPermSize=256m", "-Djava.net.preferIPv4Stack=true", "-Djboss.modules.system.pkgs=org.jboss.byteman", "-Djava.awt.headless=true", "-Djboss.modules.policy-permissions=true", "-Dorg.jboss.boot.log.file=/jboss/standalone/log/server.log", "-Dlogging.configuration=file:/jboss/standalone/configuration/logging.properties", "-jar", "/jboss/jboss-modules.jar", "-mp", "/jboss/modules", "-jaxpmodule", "javax.xml.jaxp-provider", "org.jboss.as.standalone", "-Djboss.home.dir=/jboss", "-Djboss.server.base.dir=/jboss/standalone", "-b", "0.0.0.0"]

## Removed args that have defaults and added memory limit options
ENTRYPOINT ["java", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap", "-XX:MaxRAMFraction=1", "-jar", "/jboss/jboss-modules.jar", "-mp", "/jboss/modules", "org.jboss.as.standalone", "-Djboss.home.dir=/jboss", "-b", "0.0.0.0"]
