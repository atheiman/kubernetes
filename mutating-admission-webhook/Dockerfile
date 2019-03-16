# build stage
FROM golang:alpine AS build-env
RUN apk update && apk add curl git
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

RUN mkdir -p /go/src/
COPY . /go/src/mutating-admission-webhook
WORKDIR /go/src/mutating-admission-webhook
RUN dep ensure

RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o webhook
RUN ls -alh

FROM alpine:latest

COPY --from=build-env /go/src/mutating-admission-webhook/webhook .
ENTRYPOINT ["/webhook"]
