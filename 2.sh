docker run -d --name test nginx:alpine
docker exec -it test sh
exit
docker ps
docker stop test
docker start test
docker rm -vf test

=======

vim 1.py

from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello_world():
  return f'Hello {os.getenv("NAME")}! I am a Flask application'

if __name__ == '__main__':
  app.run(host='0.0.0.0')


vim Dockerfile

FROM python:alpine
ENV NAME=Eli
WORKDIR /app
COPY 1.py /app/1.py
RUN pip install flask
CMD ["python", "/app/1.py"]

docker build -t myimage1 .
docker run --name myapp1 -p 5001:5000 myimage1

=======

docker network create example
docker run -d  --name container1 --network example nginx:alpine
docker run -d  --name container2 --network example nginx:alpine

docker network inspect example
docker exec -it container1 sh
curl http://container2

=======

vim docker-compose.yaml

services:
  nginx:
    image: nginx:alpine
    container_name: my_nginx
    environment:
      - NGINX_HOST=localhost
      - NGINX_PORT=80
      - ELI=test123
    ports:
      - "8080:80"
    restart: always

  alpine:
    image: alpine:latest
    container_name: my_alpine
    command: ["sleep", "infinity"]
    environment:
      - MY_VAR=example
    restart: always

docker compose up -d

docker tag myimage1 elimutch/devops1125:v0.1
docker push elimutch/devops1125:v0.1

==========

# Stage 1: Build
FROM golang:1.20 AS builder
WORKDIR /app

# Create main.go inline
RUN echo 'package main\nimport "fmt"\nfunc main() { fmt.Println("Hello, Multi-Stage Docker!") }' > main.go

# Build the Go binary
RUN go build -o myapp main.go

# Stage 2: Create lightweight runtime image
FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/myapp .
CMD ["./myapp"]
