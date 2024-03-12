FROM openjdk:8-jre-alpine

MAINTAINER Tom Cheung <cheungtom@hotmail.com>, Bastian Klein<basklein@amazon.com>
VOLUME /tmp
VOLUME /target

RUN addgroup -S demo-app && adduser -S demo-app -G demo-app
USER demo-app:demo-app
ARG DEPENDENCY=target/dependency
#COPY ${DEPENDENCY}/BOOT-INF/lib /app/lib
#COPY ${DEPENDENCY}/META-INF /app/META-INF
#COPY ${DEPENDENCY}/BOOT-INF/classes /app
#COPY ${DEPENDENCY}/org /app/org

EXPOSE 8080

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-cp","app:app/lib/*", "com/amazon/aws/SpringBootSessionApplication"]
