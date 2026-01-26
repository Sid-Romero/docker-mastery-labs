# Lab 72: Docker: Optimizing API Performance with Efficient Builds

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)

> **Auto-generated lab** - Created on 2026-01-26

## Description

This lab demonstrates how to improve API performance by optimizing Docker build processes. You'll build a simple Python Flask API and optimize the Dockerfile for smaller image size and faster build times, mimicking the benefits of moving from serverless to a containerized environment.

## Learning Objectives

- Understand Dockerfile best practices for performance.
- Implement multi-stage builds for smaller image size.
- Use Docker Compose to run and test the API.
- Measure and compare image sizes before and after optimization.

## Prerequisites

- Docker installed and running
- Docker Compose installed (optional, but recommended)
- Basic knowledge of Python and Flask (optional)

## Lab Steps

### Step 1: Create a Simple Flask API

First, let's create a simple Flask API. Create a directory named `api` and inside it, create a file named `app.py` with the following content:

```python
from flask import Flask
import time
import os

app = Flask(__name__)

@app.route('/')
def hello_world():
    # Simulate some processing time
    time.sleep(0.1)  # 100ms delay
    return 'Hello, World! This is a containerized API!\n'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
```

Also, create a `requirements.txt` file in the same directory with the following:

```
Flask
```

This API simply returns "Hello, World!" after a 100ms delay to simulate some processing.

### Step 2: Create a Basic Dockerfile

Now, create a file named `Dockerfile` in the `api` directory with the following content. This is a basic, unoptimized Dockerfile:

```dockerfile
FROM python:3.9-slim-buster

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

EXPOSE 8080

CMD ["python3", "app.py"]
```

### Step 3: Build and Run the Initial Image

Build the Docker image using the following command from the `api` directory:

```bash
docker build -t api-unoptimized .
```

Run the image:

```bash
docker run -d -p 8080:8080 api-unoptimized
```

Test the API by visiting `http://localhost:8080` in your browser. You should see "Hello, World!" after a slight delay.

Check the image size:

```bash
docker image ls api-unoptimized
```

Note the size of the image. We'll try to reduce it in the next steps.

### Step 4: Optimize the Dockerfile using Multi-Stage Builds

Now, let's optimize the Dockerfile using multi-stage builds. Replace the contents of `Dockerfile` with the following:

```dockerfile
# Builder stage
FROM python:3.9-slim-buster AS builder

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

# Final stage
FROM python:3.9-slim-buster

WORKDIR /app

COPY --from=builder /app/ ./

EXPOSE 8080

CMD ["python3", "app.py"]
```

This Dockerfile uses two stages: a `builder` stage to install dependencies and a final stage to copy the necessary files. This helps reduce the final image size by not including the build tools and intermediate files.

### Step 5: Build and Run the Optimized Image

Build the optimized Docker image:

```bash
docker build -t api-optimized .
```

Run the optimized image:

```bash
docker run -d -p 8081:8080 api-optimized
```

Test the API by visiting `http://localhost:8081` in your browser.  You should see the same result as before.

Check the image size:

```bash
docker image ls api-optimized
```

Compare the size of `api-optimized` with `api-unoptimized`. You should see a significant reduction in size.

Stop and remove the containers:

```bash
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
```

### Step 6: Further Optimization (Optional)

For further optimization, you can explore:

*   Using a smaller base image (e.g., `python:3.9-slim` instead of `python:3.9-slim-buster` if you don't need specific Debian packages).
*   Using `.dockerignore` file to exclude unnecessary files from being copied into the image.
*   Caching Docker layers effectively by ordering commands in the Dockerfile based on frequency of change.


<details>
<summary> Hints (click to expand)</summary>

1. Make sure you are in the `api` directory when building the image.
2. Use the `--no-cache-dir` option with `pip3 install` to reduce image size.
3. Ensure the `requirements.txt` file is in the same directory as the `app.py` file.
4. Double-check that you are using the correct port when testing the API after running the container.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The solution involves using multi-stage Docker builds to separate the dependency installation from the final application image. This reduces the final image size by excluding unnecessary build tools and intermediate files. The `pip3 install --no-cache-dir` command is also crucial for minimizing the size of the installed packages. Comparing the image sizes before and after optimization demonstrates the effectiveness of this technique.

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
