# Lab 71: Kubernetes: Deploying a Simple Workflow with Temporal

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)

> **Auto-generated lab** - Created on 2026-01-25

## Description

This lab demonstrates deploying a basic Temporal workflow application on Kubernetes.  It covers creating the necessary Kubernetes resources and deploying a sample worker and client application that interact with the Temporal service.

## Learning Objectives

- Deploy a Temporal cluster on Kubernetes.
- Define Kubernetes deployments and services for Temporal worker and client applications.
- Understand the interaction between Temporal clients, workers, and the Temporal service.

## Prerequisites

- kubectl installed and configured to connect to a Kubernetes cluster (minikube, Docker Desktop with Kubernetes enabled, or a cloud-based cluster).
- Helm installed (optional, but recommended for installing Temporal).
- Basic understanding of Kubernetes concepts (Deployments, Services, Pods).
- Docker installed.

## Lab Steps

### Step 1: Deploy Temporal Cluster using Helm

We will deploy a basic Temporal cluster using Helm. This is the easiest way to get started. First, add the Temporal Helm repository:

```bash
helm repo add temporal https://temporalio.github.io/helm-charts/
helm repo update
```

Now, install Temporal. We'll use a simple, non-production configuration for this lab.  Consider using a namespace dedicated to temporal.

```bash
kubectl create namespace temporal-system
helm install temporal temporal/temporal-cluster -n temporal-system
```

Verify that the Temporal cluster is running by checking the status of the pods in the `temporal-system` namespace:

```bash
kubectl get pods -n temporal-system
```

It may take a few minutes for all the pods to become ready.

### Step 2: Create a Simple Temporal Workflow Application

We will use a simple "Hello World" workflow for this lab.  First, create a directory for your application:

```bash
mkdir temporal-app
cd temporal-app
```

Create a `Dockerfile` for the worker:

```dockerfile
FROM python:3.9-slim-buster

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY worker.py .

CMD ["python", "worker.py"]
```

Create a `requirements.txt` file:

```text
temporalio
temporalio[client]
```

Create a `worker.py` file:

```python
import asyncio
import temporalio.client
import temporalio.worker

from temporalio import activity, workflow

@activity.defn
async def get_greeting(name: str) -> str:
    return f"Hello, {name}!"

@workflow.defn
class GreetingWorkflow:
    @workflow.run
    async def run(self, name: str) -> str:
        return await temporalio.client.execute_activity(get_greeting, name, start_to_close_timeout=timedelta(seconds=5))


async def main():
    client = await temporalio.client.Client.connect("localhost:7233")

    worker = temporalio.worker.Worker(
        client,
        task_queue="my-task-queue",
        workflows=[GreetingWorkflow],
        activities=[get_greeting],
    )
    async with worker:
        print("Worker started, press Ctrl+C to exit")
        await asyncio.Future()


if __name__ == "__main__":
    asyncio.run(main())

from datetime import timedelta
```

Create a `client.py` file:

```python
import asyncio
from temporalio import client


async def main():
    temporal_client = await client.Client.connect("localhost:7233")

    workflow = await temporal_client.start_workflow(
        "GreetingWorkflow",
        "World",
        id="my-workflow-id",
        task_queue="my-task-queue",
    )

    print(f"Workflow result: {await workflow.result()}")


if __name__ == "__main__":
    asyncio.run(main())
```

### Step 3: Build and Push the Worker Image

Build the Docker image for the worker:

```bash
docker build -t my-temporal-worker .
```

Tag the image with your Docker Hub username or your private registry:

```bash
docker tag my-temporal-worker <your-dockerhub-username>/my-temporal-worker
```

Push the image to your registry:

```bash
docker push <your-dockerhub-username>/my-temporal-worker
```

Repeat the same process for the client if you decide to containerize it.

### Step 4: Deploy the Worker to Kubernetes

Create a Kubernetes deployment file named `worker-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: temporal-worker
spec:
  replicas: 1
  selector:
    matchLabels:
      app: temporal-worker
  template:
    metadata:
      labels:
        app: temporal-worker
    spec:
      containers:
      - name: worker
        image: <your-dockerhub-username>/my-temporal-worker
        imagePullPolicy: Always
        env:
        - name: TEMPORAL_HOST
          value: temporal-frontend.temporal-system.svc.cluster.local

```

Apply the deployment:

```bash
kubectl apply -f worker-deployment.yaml
```

Create a Kubernetes service for the worker (if needed, but typically the worker doesn't need a service): This is not needed in this example, but added for completeness sake.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: temporal-worker-service
spec:
  selector:
    app: temporal-worker
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 8080
```

```bash
kubectl apply -f worker-service.yaml
```

Verify that the worker pod is running:

```bash
kubectl get pods
```

### Step 5: Run the Client from your Local Machine

Ensure that the Temporal frontend service is accessible from your local machine.  You can use port forwarding for this purpose. This is a development setup. For production, you would expose the Temporal frontend service appropriately (e.g., via Ingress).

```bash
kubectl port-forward -n temporal-system service/temporal-frontend 7233:7233
```

Now, run the `client.py` script from your local machine:

```bash
python client.py
```

You should see the output: `Workflow result: Hello, World!`


<details>
<summary> Hints (click to expand)</summary>

1. If the Temporal pods are not starting, check the logs for errors. Common issues include incorrect database configuration or resource constraints.
2. Ensure that the `TEMPORAL_HOST` environment variable in the worker deployment is correctly set to the Temporal frontend service address.
3. If the client cannot connect to the Temporal service, verify that the port forwarding is correctly configured and that the Temporal frontend service is accessible from your local machine.
4. Double check the task queue name in worker.py and client.py. They must match.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The complete solution involves deploying a Temporal cluster using Helm, creating a Docker image for a simple Temporal worker application, deploying the worker to Kubernetes, and running a client application locally that interacts with the Temporal service.  Port forwarding allows the local client to communicate with the Kubernetes-deployed Temporal service. For production setup, proper ingress and service configurations are required.

</details>


---

## Notes

- **Difficulty:** Medium
- **Estimated time:** 45-75 minutes
- **Technology:** Kubernetes

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
