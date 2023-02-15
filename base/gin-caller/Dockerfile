FROM golang:1.19-alpine

WORKDIR /app


COPY *.go ./

RUN go build -o /go-docker-caller

CMD [ "/go-docker-caller" ]