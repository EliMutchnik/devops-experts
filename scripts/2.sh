docker run --name test -p 8080:80 -d nginx:alpine
docker exec -it test sh
exit

docker ps
docker stop test
docker start test
docker rm -vf test

=======
# Create Python script
vim 1.py

from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello_world():
  return f'Hello {os.getenv("NAME")}! I am a Flask application'

if __name__ == '__main__':
  app.run(host='0.0.0.0')


# Create Dockerfile
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
### Without multi-stage build (Dockerfile.heavy)

FROM golang:1.21-alpine
WORKDIR /app
RUN echo -e 'package main\nimport "fmt"\nfunc main() { fmt.Println("Hello Class!") }' > main.go
RUN go build -o myapp main.go
CMD ["./myapp"]

docker build -t myimage-heavy .

### With multi-stage build (Dockerfile.slim)

# STAGE 1: Build
FROM golang:1.21-alpine AS builder
WORKDIR /app
RUN echo -e 'package main\nimport "fmt"\nfunc main() { fmt.Println("Hello Class!") }' > main.go
RUN go build -o myapp main.go

# STAGE 2: Final Image
FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/myapp .
CMD ["./myapp"]

docker build -t myimage-slim .
