FROM alpine:latest
WORKDIR /test
ADD test.sh test.sh
CMD sh /test/test.sh
