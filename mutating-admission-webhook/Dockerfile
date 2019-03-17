# build stage
FROM golang:alpine AS go-build
RUN apk update && apk add curl git
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
RUN mkdir -p /go/src/
COPY . /go/src/mutating-admission-webhook
WORKDIR /go/src/mutating-admission-webhook
RUN dep ensure
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o webhook

FROM alpine:latest
COPY --from=go-build /go/src/mutating-admission-webhook/webhook .
ENTRYPOINT ["/webhook"]
