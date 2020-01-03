FROM openjdk:8-jre-alpine AS builder
ARG SBT_BIN=/sbt/bin/sbt
ARG BUILD_NUMBER
ARG GIT_COMMIT

ENV SBT_VERSION 1.3.6
ENV BUILD_NUMBER ${BUILD_NUMBER}
ENV GIT_COMMIT ${GIT_COMMIT}

RUN apk add curl bash tar

RUN set -ex; \
    curl -sL https://piccolo.link/sbt-$SBT_VERSION.tgz | \
    tar xz -C /

RUN mkdir -p /app

# this prevents re-downloading a bunch of scala-sbt stuff in case of later failure
RUN $SBT_BIN -no-colors sbtVersion

COPY . /app
WORKDIR /app

RUN $SBT_BIN -no-colors clean core/assembly

RUN sh -c "chmod +x scala-steward.jar"

FROM openjdk:8-jre-alpine


COPY --from=builder "/app/scala-steward.jar" /app/run.jar
WORKDIR /app

CMD ["/app/run.jar"]

