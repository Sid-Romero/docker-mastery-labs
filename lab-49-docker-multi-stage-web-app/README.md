# Lab 49: Docker: Building a Simple Web App with Multi-Stage Builds

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)

> **Auto-generated lab** - Created on 2026-01-03

## Description

This lab guides you through creating a simple web application and containerizing it using Docker multi-stage builds. You will learn how to optimize your Docker images by separating the build environment from the runtime environment, resulting in smaller and more secure images.

## Learning Objectives

- Understand the benefits of Docker multi-stage builds.
- Create a Dockerfile with multiple stages for building and running a web application.
- Optimize Docker image size by using different base images for build and runtime.
- Learn how to copy artifacts between Docker build stages.

## Prerequisites

- Docker installed and running on your local machine (Docker Desktop is recommended).
- Basic understanding of Docker concepts (images, containers, Dockerfiles).

## Lab Steps

### Step 1: Create a Simple Web Application

Let's start by creating a simple Python web application using Flask. Create a directory named `webapp` and inside it, create a file named `app.py` with the following content:

```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, Docker!\'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
```

Next, create a `requirements.txt` file in the same directory with the following content:

```
Flask
```

This file lists the Python dependencies required by our application.

### Step 2: Create a Dockerfile with Multi-Stage Build

Now, let's create a `Dockerfile` in the `webapp` directory to containerize our application. We will use a multi-stage build to separate the build environment (where dependencies are installed) from the runtime environment (where the application is executed).

Create a `Dockerfile` with the following content:

```dockerfile
# Stage 1: Build stage
FROM python:3.9-slim-buster AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Stage 2: Runtime stage
FROM python:3.9-slim-buster

WORKDIR /app

COPY --from=builder /app . 

EXPOSE 5000

CMD ["python", "app.py"]
```

This Dockerfile defines two stages:

*   **builder**: Uses a full Python image to install dependencies and copy the application code.
*   **runtime**: Uses a minimal Python image and copies only the necessary files from the `builder` stage.  This reduces the final image size.

### Step 3: Build the Docker Image

Navigate to the `webapp` directory in your terminal and build the Docker image using the following command:

```bash
docker build -t my-web-app .
```

This command builds the image and tags it as `my-web-app`.

### Step 4: Run the Docker Container

Run the Docker container using the following command:

```bash
docker run -d -p 5000:5000 my-web-app
```

This command runs the container in detached mode (`-d`) and maps port 5000 on your host machine to port 5000 inside the container (`-p 5000:5000`).

Now, open your web browser and navigate to `http://localhost:5000`. You should see the "Hello, Docker!" message.

### Step 5: Verify Image Size

Check the size of the image using the following command:

```bash
docker images my-web-app
```

Notice the size of the image. If you were to build the image without multi-stage builds, the image size would be significantly larger because it would include the development tools and packages that are not needed at runtime.

### Step 6: Clean Up

Stop and remove the container:

```bash
docker stop <container_id>
docker rm <container_id>
```

Replace `<container_id>` with the actual container ID.

You can also remove the image:

```bash
docker rmi my-web-app
```


<details>
<summary> Hints (click to expand)</summary>

1. Ensure the `requirements.txt` file is in the same directory as `app.py` when running `pip install`.
2. Double-check the port mapping when running the container to ensure you can access the application in your browser.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The core of the solution is the Dockerfile, which leverages multi-stage builds. The first stage installs all dependencies, and the second stage copies only the necessary application files, resulting in a smaller and more secure final image.  Consider using more specific versions of python for consistency. Consider using a linter in the first stage to improve code quality. A `.dockerignore` file can further reduce image size.

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
