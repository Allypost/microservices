FROM golang:1-alpine as builder
RUN apk add binutils bash
WORKDIR /usr/src/app
COPY go.mod go.sum ./
RUN go mod download && go mod verify
COPY . .
RUN ALLY_OUTPUT_PATH="/tmp/ip" ./build.sh

FROM alpine:3
COPY --from=builder /tmp/ip /bin/svc-ip
LABEL org.opencontainers.image.authors="me@allypost.net"
LABEL description="Simple service that returns the IP address that connected to it. Tries to follow various proxy headers if present."
EXPOSE 8080
CMD ["svc-ip"]
