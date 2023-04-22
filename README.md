# Create a simple Go app, Dockerize and push to Google Cloud Registry

## 0. Pre requisites: 
* Go installed
* Docker installed
* Google Cloud account
* Google Cloud CLI installed

## 1. Create a simple Go app
Create a new directory for the project
```bash
mkdir go-gcloud
```
Change directory using cm command
```bash
cd go-gcloud
```
Initialize go.mod file 
```bash
go mod init go-gcloud
```
Create new main.go file using touch command
```bash
touch main.go
```

In the `main.go` file, add the following content. It is a simple app which shows "Hello, World!" message.
```go
package main

import (
	"log"

	"github.com/gofiber/fiber/v2"
)

func main() {
	app := fiber.New()

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})

	log.Fatal(app.Listen(":3000"))
}
```
Run `go mod tidy` once more
```bash
go mod tidy
```

Generate an executable using `go build` command 
```bash
go build -o ./out/dist .
```
* `build` is the command to build the executable binary from the source code.
* `-o` is a flag that specifies the output file name or path for the generated binary file. In this case, it is set to `./out/dist`, which means that the binary file will be named dist and will be placed in the out directory, which is located in the current directory.
* `.` is the path to the directory containing the Go source code to be compiled.

## 2. Prepare Dockerfile
Create a new `Dockerfile`
```bash
touch Dockerfile
```
Add following content to the `Dockerfile`

```Dockerfile
# specify the enviornment. Here we will be using golang container
FROM golang:1.19-alpine
# working directory (we can name it whatever we want)
WORKDIR /app
# copy go.mod to workdir
COPY go.mod .
# copy go.sum to workdir
COPY go.sum .
# download the dependencies
RUN go mod tidy
# copy all the files to workdir
COPY . .
# build go application. it will be a executable binary in the out directory
RUN go build -o ./out/dist .
# entry point 
CMD ./out/dist
```

Build image from Dockerfile
```bash
docker build -t app .
```
* `build` is a command used to build an image from a Dockerfile.
* `-t` is a flag that is used to specify a tag for the image that is being built. In this case, the tag is set to app.
* `app` is the name of the image that is being built.
* `.` specifies the build context for the Dockerfile. In this case, it is set to the current directory.