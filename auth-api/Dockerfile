FROM golang:1.18.2
WORKDIR /app
COPY . .
RUN go mod init github.com/bortizf/microservice-app-example/tree/master/auth-api \
    && go mod tidy \
    && go build -o auth-api
EXPOSE 8081
CMD ["./auth-api"]