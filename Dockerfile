FROM golang:1.12 AS go

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir /src
WORKDIR /src
RUN git clone https://github.com/honeytrap/honeytrap.git
ARG LDFLAGS=""

WORKDIR /src/honeytrap
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -tags="" -ldflags="$(go run scripts/gen-ldflags.go)" -o /go/bin/app .

FROM alpine

RUN apk --update upgrade && apk add curl ca-certificates && rm -rf /var/cache/apk/*
RUN apk add ca-certificates && update-ca-certificates


RUN mkdir /config /data

COPY --from=go /go/bin/app /honeytrap/honeytrap

#ENTRYPOINT [ "curl", "elasticsearch.local.development" ]
ENTRYPOINT ["/honeytrap/honeytrap", "--config", "/config/config.toml", "--data", "/data/"]

EXPOSE 22 5555 80
