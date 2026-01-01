# Lab 38: Kubernetes: Rolling Updates with Readiness Probes

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)

> **Auto-generated lab** - Created on 2026-01-01

## Description

This lab demonstrates how to perform rolling updates in Kubernetes with readiness probes to ensure minimal downtime and a smooth transition. You will deploy an application, update its version, and observe the rolling update process.

## Learning Objectives

- Understand the concept of rolling updates in Kubernetes.
- Learn how to configure readiness probes for application health checks.
- Observe the behavior of rolling updates with readiness probes.
- Understand the impact of readiness probe configuration on the update process.

## Prerequisites

- kubectl installed and configured to connect to a Kubernetes cluster (minikube, Docker Desktop, or a cloud provider cluster)
- Basic understanding of Kubernetes deployments and services

## Lab Steps

### Step 1: Step 1: Deploy the Initial Application

First, we'll deploy a simple application. Create a file named `app.yaml` with the following content:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: nginx:1.21
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10

---
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  selector:
    app: my-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
```

Apply the deployment and service:

```bash
kubectl apply -f app.yaml
```

Verify that the pods are running and the service is available:

```bash
kubectl get pods
kubectl get service my-app-service
```

Note the external IP or port of the service. If using minikube, use `minikube service my-app-service --url` to get the URL.


### Step 2: Step 2: Simulate a New Application Version

Now, let's simulate a new version of the application. We'll modify the `app.yaml` file to use a different Nginx version (e.g., 1.25) and introduce a delay in the readiness probe to mimic a slightly longer startup time for the new version.  Update the `image` field in the Deployment spec to `nginx:1.25` and increase `initialDelaySeconds` to `15` in the readiness probe.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: nginx:1.25
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 10
```

Apply the updated configuration:

```bash
kubectl apply -f app.yaml
```

### Step 3: Step 3: Observe the Rolling Update

Monitor the rolling update process using the following command:

```bash
kubectl rollout status deployment/my-app
```

Also, observe the pods being created and terminated:

```bash
kubectl get pods -w
```

Notice how Kubernetes gradually replaces the old pods with the new ones. The readiness probe ensures that new pods are only added to the service once they are ready to serve traffic.

While the update is in progress, continuously access the service using the external IP or port you noted earlier. You should observe that the service remains available throughout the update.


### Step 4: Step 4: Test Readiness Probe Impact

Now, let's intentionally break the readiness probe to see its impact.  Modify the `app.yaml` file again. This time, change the `path` in the `httpGet` of the readiness probe to a non-existent path like `/nonexistent`. This will cause the readiness probe to fail.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: nginx:1.25
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            path: /nonexistent
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
```

Apply the change:

```bash
kubectl apply -f app.yaml
```

Observe the rolling update status and pod status:

```bash
kubectl rollout status deployment/my-app
kubectl get pods -w
```

You'll notice that the pods are continuously restarting because the readiness probe is failing. The deployment may get stuck or take a very long time to complete because Kubernetes is unable to determine when the new pods are ready. This highlights the importance of a correctly configured readiness probe.


### Step 5: Step 5: Cleanup

Delete the deployment and service:

```bash
kubectl delete -f app.yaml
```


<details>
<summary> Hints (click to expand)</summary>

1. If the service doesn't get an external IP, try using `minikube tunnel` if you're on minikube.
2. Ensure your readiness probe accurately reflects the health of your application.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The solution involves deploying an Nginx application, simulating a new version by changing the image tag, and observing the rolling update process. The readiness probe plays a crucial role in ensuring that only healthy pods are added to the service, preventing downtime during the update. Breaking the readiness probe demonstrates the importance of properly configuring it.

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
