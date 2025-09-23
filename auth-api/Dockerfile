FROM golang:1.24
WORKDIR /app
COPY go.mod ./
COPY go.sum ./
COPY . .
RUN go mod tidy
RUN go build -o auth-api
EXPOSE 8081
CMD ["./auth-api"]