# Lab 41: Self-Hosted Address Validation with Docker

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)

> **Auto-generated lab** - Created on 2026-01-02

## Description

This lab demonstrates how to containerize a simplified address validation application using Docker. You will learn to build a Docker image, use Docker Compose to manage dependencies, and expose the service for local access, simulating a self-hosted address validation tool.

## Learning Objectives

- Understand how to Dockerize a Python application.
- Learn to use Docker Compose to manage multiple containers.
- Practice exposing a service through Docker's port mapping.

## Prerequisites

- Docker installed and running (Docker Desktop or Docker Engine)
- Basic understanding of Docker concepts (images, containers, Dockerfile)
- Python 3.7+ installed (for local testing, but not mandatory if relying on Docker completely)

## Lab Steps

### Step 1: Set up the Application Directory

Create a new directory for your project and navigate into it.

```bash
mkdir address-validation
cd address-validation
```

Create the following files: `app.py`, `Dockerfile`, `docker-compose.yml`, `requirements.txt`

### Step 2: Create a Simple Address Validation App (app.py)

Create a basic Flask application that simulates address validation.  This example doesn't actually validate, but returns a canned response.

```python
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/validate', methods=['POST'])
def validate_address():
    data = request.get_json()
    address = data.get('address')

    # Simulate validation logic (replace with real validation)
    if address:
        validation_result = {
            'address': address,
            'is_valid': True,
            'confidence': 0.95
        }
        return jsonify(validation_result), 200
    else:
        return jsonify({'error': 'Address is required'}), 400

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
```

### Step 3: Define Dependencies (requirements.txt)

Specify the Python dependencies for the application.

```
Flask
```

### Step 4: Create the Dockerfile

Create a `Dockerfile` to build the Docker image. This file should:

1.  Use a Python base image.
2.  Set the working directory.
3.  Copy the `requirements.txt` file and install the dependencies.
4.  Copy the application code.
5.  Define the command to run the application.

```dockerfile
FROM python:3.9-slim-buster

WORKDIR /app

COPY requirements.txt . 
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

CMD ["python", "app.py"]
```

### Step 5: Define the Docker Compose Configuration (docker-compose.yml)

Create a `docker-compose.yml` file to define the service. This file should:

1.  Define a service named `address-validation`.
2.  Specify the `Dockerfile` to build the image.
3.  Map port 5000 on the host to port 5000 in the container.

```yaml
version: '3.8'
services:
  address-validation:
    build: .
    ports:
      - "5000:5000"
```

### Step 6: Build and Run the Application

Build the Docker image and start the container using Docker Compose.

```bash
docker-compose up --build
```

This command builds the image (if it doesn't exist) and starts the container. The `--build` flag ensures that the image is rebuilt if the `Dockerfile` has changed.

### Step 7: Test the Application

Send a POST request to the `/validate` endpoint to test the application. You can use `curl` or any other HTTP client.

```bash
curl -X POST -H "Content-Type: application/json" -d '{"address": "1600 Amphitheatre Parkway, Mountain View, CA"}' http://localhost:5000/validate
```

You should see a JSON response indicating that the address is valid (according to the simulated validation logic).

### Step 8: Clean Up

Stop the Docker Compose environment.

```bash
docker-compose down
```


<details>
<summary> Hints (click to expand)</summary>

1. Ensure your Dockerfile correctly copies the requirements.txt file.
2. Double-check that the port mapping in docker-compose.yml is correct.
3. If you get a 'ModuleNotFoundError', verify that the dependencies are correctly installed in the Docker image.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The solution involves creating a Flask application that simulates address validation, defining its dependencies, and containerizing it using Docker. Docker Compose is used to manage the application's container. The application is then accessible via localhost:5000. This setup simulates a self-hosted address validation service.

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
