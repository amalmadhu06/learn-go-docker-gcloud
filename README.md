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

## 2. Dockerize
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

Test the container is working fine
```bash
docker run -p 8888:80 app
```
* `docker run` is the command to run a Docker container.
* `-p 8888:80` is a flag that maps port 80 inside the container to port 8888 on the host machine.We can access the application inside the container by going to `http://localhost:8888` on our host machine's web browser.
* `app` is the name of the Docker image that the container will be based on. The Docker engine will look for an image named app locally on the machine, and if it doesn't exist, it will try to pull it from a Docker registry.

Open your browser, and go to `localhost:8888`
You will be be able to bee
```go
Hello, World!
```

## Push image to GCloud Container Registry
Now that we have successfully generated Docker image for our project, let's try to push this image to Google Cloud Container Registry.

* Make sure you have a Google Cloud Account , Google Cloud CLI installed and you have created a sample project in Google Cloud. 

### Login to Google Cloud from command line using 
```bash
gcloud auth login
```
This will open a new tab in browser and ask you to select account and authenticate

### Tag the image

* Go to Google Cloud Console/Platform and select your project. 
* Copy project ID 

In the terminal, 
tag the image with registry address
```bash
docker tag app gcr.io/<project-id-here>/app
```
* `docker tag` is the command to tag a Docker image with a new name or a different registry address.
* `app` is the name of the Docker image that will be tagged.
* `gcr.io/<project-id-here>/app` is the new name that the image will be tagged with. 
* `gcr.io` is the Docker registry URL, 
* `app` in the end is the name of the image in the registry.

Next, push the image
```bash
docker push gcr.io/<project-id-here>/app
```
Go to Google Cloud Platform --> Select Project --> Container Registry and verify the image was pushed

## Create Cloud Run
Let's create Cloud Run to run our application

1. Go go Google Cloud Platform
2. Select project
3. Open Cloud Run from Left panel
4. Create Service
5. Give a name to the service and select a region
6. Select container image url from Container Registry
7. In Advanced Settings, change port number to 80
8. In Authentication, check `Allow unauthenticated invocations` and `Allow all traffic`
9. Click on create and wait for it to complete

You will get a url for the service. With this url, you can access the web app