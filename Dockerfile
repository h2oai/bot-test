FROM alpine:latest
WORKDIR /test
ADD test.sh test.sh
RUN echo "test" >> test.log
CMD sh /test/test.sh



