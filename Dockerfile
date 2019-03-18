FROM golang:1.12-alpine as build

MAINTAINER Cedric Staub "cs@squareup.com"

# Dependencies
RUN apk add --no-cache --update gcc musl-dev libtool git openssl

# Copy source
RUN git clone https://github.com/square/ghostunnel.git && cd ghostunnel && go build -o /usr/bin/ghostunnel .

RUN go get -u github.com/mailhog/MailHog
RUN mv /go/bin/MailHog /usr/bin/mailhog
RUN mkdir /certs && cd /certs && openssl req -new -newkey rsa:2048 -days 365 -subj "/C=UK/ST=Warwickshire/L=Leamington/O=OrgName/OU=IT Department/CN=example.com" -nodes -x509 -keyout server.key -out server.crt

# Create a multi-stage build with the binary
FROM alpine

RUN apk add --no-cache --update libtool curl 
COPY --from=build /usr/bin/ghostunnel /usr/bin/ghostunnel
COPY --from=build /usr/bin/mailhog /usr/bin/mailhog
RUN mkdir /certs /mailhog
COPY --from=build /certs/server.key /certs/server.key
COPY --from=build /certs/server.crt /certs/server.crt
ADD docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 1025 1026 8025
