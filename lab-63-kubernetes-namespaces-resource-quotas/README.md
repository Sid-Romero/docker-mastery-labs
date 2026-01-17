# Lab 63: Kubernetes: Streamlining Infrastructure with Namespaces

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)

> **Auto-generated lab** - Created on 2026-01-17

## Description

This lab demonstrates how Kubernetes namespaces can be used to streamline infrastructure management, particularly in multi-tenant environments.  You'll learn to create namespaces, deploy applications within them, and apply resource quotas to prevent resource exhaustion and optimize resource allocation.

## Learning Objectives

- Understand the purpose and benefits of Kubernetes namespaces.
- Create and manage Kubernetes namespaces.
- Deploy applications within specific namespaces.
- Implement resource quotas to control resource consumption in namespaces.

## Prerequisites

- A running Kubernetes cluster (minikube, Docker Desktop, or a cloud-based cluster)
- kubectl installed and configured to connect to your cluster

## Lab Steps

### Step 1: Create Namespaces

Namespaces provide a way to divide cluster resources between multiple users or teams. Let's create two namespaces: `dev` and `prod`.

```bash
kubectl create namespace dev
kubectl create namespace prod
```

Verify the namespaces have been created:

```bash
kubectl get namespaces
```

You should see `dev` and `prod` in the list.

### Step 2: Deploy an Application to the 'dev' Namespace

We will deploy a simple `nginx` deployment to the `dev` namespace. Create a deployment manifest file named `nginx-dev.yaml` with the following content:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: dev
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

Apply the deployment:

```bash
kubectl apply -f nginx-dev.yaml
```

Verify the deployment:

```bash
kubectl get deployments -n dev
kubectl get pods -n dev
```

### Step 3: Deploy an Application to the 'prod' Namespace

Similarly, deploy the `nginx` application to the `prod` namespace. Create a deployment manifest file named `nginx-prod.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: prod
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

Apply the deployment:

```bash
kubectl apply -f nginx-prod.yaml
```

Verify the deployment:

```bash
kubectl get deployments -n prod
kubectl get pods -n prod
```

### Step 4: Implement Resource Quotas

Resource Quotas limit the resources that can be consumed within a namespace. This helps prevent one team's applications from consuming all available resources. Let's create a resource quota for the `dev` namespace. Create a file named `resource-quota-dev.yaml`:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
  namespace: dev
spec:
  hard:
    pods: "5"
    requests.cpu: "2"
    requests.memory: "2Gi"
    limits.cpu: "4"
    limits.memory: "4Gi"
```

Apply the resource quota:

```bash
kubectl apply -f resource-quota-dev.yaml
```

View the resource quota:

```bash
kubectl describe resourcequota compute-resources -n dev
```

Try to deploy more pods in the `dev` namespace than allowed by the quota. Edit the `nginx-dev.yaml` file to increase the number of replicas to 6 and apply the changes. Observe the error message. What does it say?

```bash
kubectl apply -f nginx-dev.yaml
```

### Step 5: Clean Up

Delete the namespaces to clean up the resources:

```bash
kubectl delete namespace dev
kubectl delete namespace prod
```


<details>
<summary> Hints (click to expand)</summary>

1. If pods are stuck in pending state, check the resource quota in the namespace. Use `kubectl describe resourcequota <quota-name> -n <namespace>`
2. Ensure kubectl is configured to connect to your Kubernetes cluster. Use `kubectl config current-context` to verify.
3. If deployments fail, check the logs of the pods for errors using `kubectl logs <pod-name> -n <namespace>`.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

This lab demonstrates a basic implementation of Kubernetes namespaces and resource quotas. Namespaces are used to logically isolate applications and resources, while resource quotas prevent resource exhaustion and ensure fair resource allocation. In a real-world scenario, you would configure more granular resource quotas based on the specific needs of each namespace. You can also combine namespaces and resource quotas with other Kubernetes features like RBAC (Role-Based Access Control) to create a secure and well-managed multi-tenant environment.

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
