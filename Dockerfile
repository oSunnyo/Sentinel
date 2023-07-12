ARG BASE_IMAGE

FROM ${BASE_IMAGE} as builder
WORKDIR app

ARG JAR_FILE
COPY ${JAR_FILE} app.jar
RUN java -Djarmode=layertools -jar app.jar extract

FROM ${BASE_IMAGE}
LABEL maintainter="Magus <om@magustek.com>"

WORKDIR app
COPY --from=builder app/dependencies/ ./
COPY --from=builder app/spring-boot-loader/ ./
COPY --from=builder app/snapshot-dependencies/ ./
COPY --from=builder app/application/ ./

ENTRYPOINT ["java","org.springframework.boot.loader.JarLauncher"]

EXPOSE 8080