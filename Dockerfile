FROM golang:1.19-alpine

WORKDIR /app

COPY go.mod ./
COPY go.sum ./

RUN go mod download

COPY . .

ENV GOPROXY=https://goproxy.io

RUN go build -o ./out/dist .

CMD ["/app/out/dist"]
