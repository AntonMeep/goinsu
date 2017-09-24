FROM alpine:latest

COPY goinsu /usr/local/bin/goinsu

ENTRYPOINT ["goinsu"]
