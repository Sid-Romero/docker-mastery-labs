# Lab 07: Helm: Git as a Database Anti-Pattern Avoidance

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Helm](https://img.shields.io/badge/Helm-0F1689?logo=helm&logoColor=white)

> **Auto-generated lab** - Created on 2025-12-27

## Description

This lab demonstrates how to manage application configurations using Helm, avoiding the anti-pattern of storing configurations directly in Git. We'll build a simple application and manage its configurations using Helm values and templates.

## Learning Objectives

- Understand the problems with using Git as a database for application configuration.
- Learn how to create a Helm chart.
- Manage application configurations using Helm values files.
- Template Kubernetes manifests using Helm.
- Deploy and manage applications with Helm.

## Prerequisites

- kubectl installed and configured to connect to a Kubernetes cluster (minikube, Docker Desktop, or similar)
- Helm installed (version 3 or later)
- Basic understanding of Kubernetes concepts (Deployments, Services, ConfigMaps)
- Basic understanding of Docker

## Lab Steps

### Step 1: 1. Create a Simple Application

First, let's create a simple application that reads configuration from environment variables. This application will be a basic HTTP server written in Python. Create a file named `app.py`:

```python
import os
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    message = os.environ.get('MESSAGE', 'Hello, World!')
    return f'<h1>{message}</h1>'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
```

Next, create a `requirements.txt` file:

```
Flask
```

Finally, create a `Dockerfile` to containerize the application:

```dockerfile
FROM python:3.9-slim-buster

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
```

Build the Docker image:

```bash
docker build -t my-app .
```


### Step 2: 2. Create a Helm Chart

Now, let's create a Helm chart for our application. Use the `helm create` command to scaffold a new chart:

```bash
helm create my-app-chart
```

This will create a directory named `my-app-chart` with the basic structure of a Helm chart.  Clean up the default chart files by deleting the `my-app-chart/templates` directory and creating a new empty one. We'll create our own templates from scratch.

```bash
rm -rf my-app-chart/templates/*
```

### Step 3: 3. Define Kubernetes Manifests as Helm Templates

Inside the `my-app-chart/templates` directory, create a `deployment.yaml` file:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-deployment
  labels:
    app: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
      - name: my-app
        image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
        ports:
        - containerPort: 5000
        env:
        - name: MESSAGE
          value: {{ .Values.message }}
```

Next, create a `service.yaml` file:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-service
  labels:
    app: {{ .Release.Name }}
spec:
  type: ClusterIP
  ports:
  - port: 5000
    targetPort: 5000
    protocol: TCP
    name: http
  selector:
    app: {{ .Release.Name }}
```

### Step 4: 4. Configure the Helm Chart with Values

Open the `my-app-chart/values.yaml` file and modify it to include the following:

```yaml
replicaCount: 1

image:
  repository: my-app
  tag: latest

message: "Hello from Helm!"
```

This file defines the default values for the variables used in our templates. Notice how the `message` value is set here, and it will be injected as an environment variable into the container.

### Step 5: 5. Deploy the Application with Helm

Now, let's deploy the application using Helm. First, install the chart:

```bash
helm install my-app my-app-chart
```

Check the status of the deployment:

```bash
kubectl get deployments
kubectl get services
```

To see the application running, you'll need to port-forward the service to your local machine. First, find the service name (from `kubectl get services`), then run:

```bash
kubectl port-forward service/<service-name> 5000:5000
```

Open your web browser and navigate to `http://localhost:5000`. You should see the "Hello from Helm!" message.


### Step 6: 6. Customize the Configuration

Update the `my-app-chart/values.yaml` file to change the `message` to something else, such as "Hello, Custom Message!".

Alternatively, override the value during the `helm install` or `helm upgrade` command using the `--set` flag:

```bash
helm upgrade my-app my-app-chart --set message="Hello from command line!"
```

Verify the changes by refreshing your browser at `http://localhost:5000`.  The message should now reflect the updated value.  This demonstrates how Helm allows you to manage configuration without directly modifying Git repositories for every small change, preventing the anti-pattern.


### Step 7: 7. Cleanup

Uninstall the Helm release:

```bash
helm uninstall my-app
```

Delete the local chart directory:

```bash
rm -rf my-app-chart
```


<details>
<summary> Hints (click to expand)</summary>

1. If you're having trouble building the Docker image, make sure you are in the same directory as the Dockerfile.
2. If the Helm install command fails, check your Kubernetes context and make sure you are connected to the correct cluster.
3. If the application doesn't show the updated message, double-check that the port-forwarding is set up correctly and that you are accessing the correct port in your browser.
4. Remember to update the image repository in values.yaml to match the name of the image you built locally.  Consider pushing the image to a registry for broader access.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The solution involves creating a simple Python application, containerizing it with Docker, and then creating a Helm chart to deploy it to Kubernetes. The key is to use Helm values files to manage the application's configuration, avoiding the need to store configuration directly in Git. The `--set` flag provides an alternative to modifying the `values.yaml` file directly. This demonstrates a more robust and maintainable approach to managing application configurations in a Kubernetes environment.

</details>


---

## Notes

- **Difficulty:** Medium
- **Estimated time:** 45-75 minutes
- **Technology:** Helm

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
