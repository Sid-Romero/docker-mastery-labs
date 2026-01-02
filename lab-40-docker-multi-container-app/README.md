# Lab 40: Docker: Building and Orchestrating a Multi-Container App

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)

> **Auto-generated lab** - Created on 2026-01-02

## Description

This lab guides you through building a Dockerized application consisting of a simple Flask web application and a Redis cache. You'll learn how to define services, configure networking, and orchestrate them using Docker Compose.

## Learning Objectives

- Create a Dockerfile for a Python Flask application.
- Define a multi-container application using Docker Compose.
- Configure networking between Docker containers.
- Understand the basics of service orchestration with Docker Compose.

## Prerequisites

- Docker installed and running
- Docker Compose installed
- Basic understanding of Docker concepts (images, containers)
- Basic Python knowledge is helpful but not required

## Lab Steps

### Step 1: Set up the Flask Application

First, create a directory for your project and create the following files:

`app.py`:

```python
from flask import Flask
import redis
import os

app = Flask(__name__)
redis_host = os.environ.get('REDIS_HOST', 'redis')
redis_port = int(os.environ.get('REDIS_PORT', 6379))
cache = redis.Redis(host=redis_host, port=redis_port)

@app.route('/')
def hello():
    cache.incr('hits')
    return 'Hello! I have been seen {} times.\n'.format(cache.get('hits').decode())

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
```

`requirements.txt`:

```
flask
redis
```

This is a simple Flask application that connects to a Redis instance and increments a counter each time the root endpoint is accessed.


### Step 2: Create the Dockerfile

Create a `Dockerfile` in the same directory as your application files:

```dockerfile
FROM python:3.9-slim-buster

WORKDIR /app

COPY requirements.txt .  
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
```

This Dockerfile sets up a Python 3.9 environment, installs the required dependencies, copies the application code, and specifies the command to run the application.


### Step 3: Define the Docker Compose file

Create a `docker-compose.yml` file:

```yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "5000:5000"
    depends_on:
      - redis
    environment:
      REDIS_HOST: redis
  redis:
    image: redis:latest
```

This Compose file defines two services: `web` (our Flask application) and `redis`.  It builds the `web` service from the Dockerfile in the current directory, exposes port 5000, and links it to the `redis` service. The `depends_on` directive ensures that Redis starts before the web application. The `REDIS_HOST` environment variable tells the Flask app where to find the redis server.


### Step 4: Build and Run the Application

Open your terminal and navigate to the directory containing the `docker-compose.yml` file. Run the following command to build and start the application:

```bash
docker-compose up --build
```

This command will build the Docker image for the `web` service and start both the `web` and `redis` containers.  The `--build` flag ensures that the image is rebuilt if the Dockerfile has changed.


### Step 5: Test the Application

Open your web browser and navigate to `http://localhost:5000`. You should see the "Hello!" message and the number of hits incrementing each time you refresh the page.


### Step 6: Clean Up

To stop the application, press `Ctrl+C` in your terminal. To remove the containers, networks, and volumes created by Compose, run:

```bash
docker-compose down
```


<details>
<summary> Hints (click to expand)</summary>

1. Make sure your Dockerfile correctly copies the requirements.txt file and installs the dependencies.
2. Ensure that the Redis service is running before the web service attempts to connect to it. The `depends_on` directive in the Compose file helps with this.
3. If you encounter connection errors, verify that the `REDIS_HOST` environment variable is correctly set in the web service configuration.
4. If the application doesn't reflect the latest code changes, try rebuilding the Docker image using `docker-compose up --build`.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The solution involves creating a Flask application that connects to a Redis instance, defining a Dockerfile to containerize the application, and using Docker Compose to orchestrate the web application and Redis service. The `docker-compose.yml` file defines the services, their dependencies, and the necessary environment variables for communication. This setup allows for easy deployment and scaling of the application.

</details>


---

## Notes

- **Difficulty:** Medium
- **Estimated time:** 45-75 minutes
- **Technology:** Docker

##  Cleanup

Don't forget to clean up resources after completing the lab:

```bash
# Example cleanup commands (adjust based on lab content)
docker system prune -f
# or
kubectl delete -f .
# or
helm uninstall <release-name>
```

---

*This lab was auto-generated by the [Lab Generator Bot](../.github/workflows/generate-lab.yml)*
