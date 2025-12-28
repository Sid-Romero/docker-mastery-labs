# Lab 14: Docker Healthchecks and Rolling Updates

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)

> **Auto-generated lab** - Created on 2025-12-28

## Description

This lab demonstrates how to implement healthchecks in Docker containers and use them to orchestrate rolling updates, ensuring minimal downtime and resilience for your applications. We will use Docker Compose to define and manage a multi-container application.

## Learning Objectives

- Understand the importance of healthchecks in Dockerized applications.
- Implement healthchecks in a Dockerfile.
- Use Docker Compose to define and manage a multi-container application with healthchecks.
- Simulate a rolling update and observe the healthcheck-driven orchestration.

## Prerequisites

- Docker installed and running (Docker Desktop or similar)
- Docker Compose installed (included with Docker Desktop)
- Basic understanding of Docker and Docker Compose concepts

## Lab Steps

### Step 1: Create a Simple Web Application

First, create a simple web application that will be containerized. This example uses Python and Flask, but you can adapt it to your preferred language.

Create a file named `app.py`:

```python
from flask import Flask
import os
import time

app = Flask(__name__)

healthy = True

@app.route('/')
def hello_world():
    return 'Hello, World!\n'

@app.route('/health')
def health_check():
    global healthy
    if healthy:
        return 'OK', 200
    else:
        return 'Unhealthy', 500

@app.route('/break')
def break_app():
    global healthy
    healthy = False
    return 'Application marked as unhealthy', 200

@app.route('/fix')
def fix_app():
    global healthy
    healthy = True
    return 'Application marked as healthy', 200

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=False, host='0.0.0.0', port=port)
```

Create a `requirements.txt` file:

```
Flask
```

This application has three endpoints:
*   `/`: Returns a simple "Hello, World!" message.
*   `/health`: Returns "OK" with a 200 status code if the application is healthy, or "Unhealthy" with a 500 status code if it's not.
*   `/break`: Sets the application state to unhealthy.
*   `/fix`: Sets the application state to healthy.

### Step 2: Create a Dockerfile with a Healthcheck

Create a `Dockerfile` in the same directory as your application files:

```dockerfile
FROM python:3.9-slim-buster

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py ./

EXPOSE 5000

HEALTHCHECK --interval=5s --timeout=3s --retries=3 \
  CMD curl --fail http://localhost:5000/health || exit 1

CMD ["python", "app.py"]
```

This Dockerfile does the following:
*   Uses a Python 3.9 slim base image.
*   Sets the working directory to `/app`.
*   Copies the `requirements.txt` file and installs the dependencies.
*   Copies the `app.py` file.
*   Exposes port 5000.
*   Defines a healthcheck that pings the `/health` endpoint every 5 seconds. If the endpoint returns a non-200 status code or the request times out after 3 seconds, the healthcheck will fail. It retries 3 times before marking the container as unhealthy.
*   Starts the Flask application.

### Step 3: Define the Application with Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "5000:5000"
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"] # Redundant, but good for demonstration
      interval: 5s
      timeout: 3s
      retries: 3
```

This Docker Compose file defines a single service, `web`:
*   `build: .` tells Docker Compose to build the image using the `Dockerfile` in the current directory.
*   `ports: - "5000:5000"` maps port 5000 on the host to port 5000 in the container.
*   `deploy:` configures the deployment settings:
    *   `replicas: 3` specifies that we want 3 replicas of the service.
    *   `update_config:` defines the rolling update strategy:
        *   `parallelism: 1` specifies that only one container should be updated at a time.
        *   `delay: 10s` specifies that there should be a 10-second delay between updating each container.
    *   `restart_policy:` specifies that the container should be restarted if it fails.
        * `condition: on-failure` specifies to restart only if the container exits with an error code.
*   `healthcheck:` defines the healthcheck configuration. Note that this is redundant with the `HEALTHCHECK` instruction in the `Dockerfile`, but it's included here for demonstration purposes.  In a real-world scenario, you would typically define the healthcheck in the `Dockerfile` or in the `docker-compose.yml`, but not both unless you need to override the Dockerfile configuration.

Note: the compose healthcheck overrides the Dockerfile one. If you want to use the Dockerfile one, remove it from the compose file.

### Step 4: Start the Application

Start the application using Docker Compose:

```bash
docker-compose up --scale web=3 --detach
```

This command will build the image and start three replicas of the `web` service in detached mode.

Verify that the containers are running:

```bash
docker ps
```

You should see three containers running, all based on the image you just built.

### Step 5: Monitor the Healthchecks

Monitor the health status of the containers:

```bash
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
```

Initially, all containers should be healthy. It might take a few seconds for the healthchecks to pass after the containers start. You will see `(healthy)` after a while.

Access the application in your browser at `http://localhost:5000`. You should see the "Hello, World!" message.

### Step 6: Simulate a Rolling Update

Now, simulate a rolling update by making a change to the `app.py` file. For example, change the "Hello, World!" message to "Hello, Updated World!":

```python
from flask import Flask
import os
import time

app = Flask(__name__)

healthy = True

@app.route('/')
def hello_world():
    return 'Hello, Updated World!\n'

@app.route('/health')
def health_check():
    global healthy
    if healthy:
        return 'OK', 200
    else:
        return 'Unhealthy', 500

@app.route('/break')
def break_app():
    global healthy
    healthy = False
    return 'Application marked as unhealthy', 200

@app.route('/fix')
def fix_app():
    global healthy
    healthy = True
    return 'Application marked as healthy', 200

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=False, host='0.0.0.0', port=port)
```

Rebuild and redeploy the application using Docker Compose:

```bash
docker-compose up --detach --build
```

Docker Compose will perform a rolling update, updating one container at a time with a 10-second delay between updates.  During the update, you can observe the health status of the containers using `docker ps`. You should see one container being recreated while the others remain healthy.

After the update is complete, refresh your browser. You should now see the "Hello, Updated World!" message.

### Step 7: Simulate an Unhealthy Application

Simulate an unhealthy application by calling the `/break` endpoint:

```bash
curl http://localhost:5000/break
```

This will set the application's health status to unhealthy.  Now, check the status of the containers:

```bash
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
```

You should see that one of the containers is marked as unhealthy. Because of the `restart_policy: on-failure` defined in the `docker-compose.yml`, docker will restart the unhealthy container.

Fix the application by calling the `/fix` endpoint:

```bash
curl http://localhost:5000/fix
```

After a while, the container will become healthy again.

### Step 8: Clean Up

Stop and remove the containers:

```bash
docker-compose down
```


<details>
<summary> Hints (click to expand)</summary>

1. If the healthchecks are failing, double-check that your application is listening on the correct port and that the `/health` endpoint is returning the expected response.
2. Make sure your Dockerfile and docker-compose.yml files are in the same directory.
3. If the rolling update is not working as expected, check the `update_config` settings in your docker-compose.yml file.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The solution involves creating a simple Flask application with a healthcheck endpoint, defining a Dockerfile that includes a `HEALTHCHECK` instruction, and using Docker Compose to manage a multi-container deployment with rolling updates. The healthchecks ensure that only healthy containers are used during the update process, minimizing downtime.

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
