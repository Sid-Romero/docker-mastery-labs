# Lab 29: Kubernetes Pod Security Contexts

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)

> **Auto-generated lab** - Created on 2025-12-31

## Description

This lab explores Kubernetes Pod Security Contexts, allowing you to define security-related settings for Pods and Containers. You'll learn to configure user IDs, group IDs, capabilities, and more to enhance the security posture of your applications.

## Learning Objectives

- Understand the purpose and benefits of Pod Security Contexts.
- Configure user and group IDs for containers.
- Manage Linux capabilities for containers.
- Apply Security Contexts at the Pod and Container level.
- Verify the effective security settings of running containers.

## Prerequisites

- kubectl installed and configured to connect to a Kubernetes cluster (minikube or Docker Desktop)
- Basic understanding of Kubernetes Pods and Deployments

## Lab Steps

### Step 1: Step 1: Create a Namespace

Create a dedicated namespace for this lab to isolate resources.

```bash
kubectl create namespace security-context-lab
kubectl config set-context --current --namespace=security-context-lab
```

Verify the namespace is created:

```bash
kubectl get namespace security-context-lab
```

### Step 2: Step 2: Create a Pod without Security Context

Create a simple Pod definition without any Security Context specified.

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: insecure-pod
  labels:
    app: insecure-pod
spec:
  containers:
  - name: main
    image: busybox:latest
    command: ["sleep", "3600"]
EOF
```

Verify the pod is running:

```bash
kubectl get pod insecure-pod
```

Execute into the container and check the user ID:

```bash
kubectl exec -it insecure-pod -- sh
whoami
id
exit
```

Note the user ID and group ID. They are likely root (0).

### Step 3: Step 3: Create a Pod with User and Group ID Security Context

Create a Pod definition with a Security Context specifying a specific user and group ID.

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  labels:
    app: secure-pod
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
  containers:
  - name: main
    image: busybox:latest
    command: ["sleep", "3600"]
EOF
```

Verify the pod is running:

```bash
kubectl get pod secure-pod
```

Execute into the container and check the user ID:

```bash
kubectl exec -it secure-pod -- sh
whoami
id
exit
```

Note the user ID and group ID. They should now be 1000.

### Step 4: Step 4: Create a Pod with Capabilities

Create a Pod definition with a Security Context that drops specific capabilities.

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: restricted-pod
  labels:
    app: restricted-pod
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
    capabilities:
      drop:
        - ALL
  containers:
  - name: main
    image: busybox:latest
    command: ["sleep", "3600"]
  securityContext:
    capabilities:
      add:
        - NET_BIND_SERVICE
EOF
```

Verify the pod is running:

```bash
kubectl get pod restricted-pod
```

Execute into the container and try to bind to a privileged port (e.g., port 80). You'll need to install `netcat` inside the container first:

```bash
kubectl exec -it restricted-pod -- sh
apk update
apk add netcat-openbsd
nc -l -p 80
exit
```

Check if the `NET_BIND_SERVICE` is correctly added to the pod.

```bash
kubectl describe pod restricted-pod
```

Look for the `Capabilities` section to verify.

### Step 5: Step 5: Applying Security Context to a Deployment

Apply the security context to a Deployment instead of a single Pod.

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: secure-deployment
  template:
    metadata:
      labels:
        app: secure-deployment
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
      containers:
      - name: main
        image: busybox:latest
        command: ["sleep", "3600"]
EOF
```

Verify the deployment is running:

```bash
kubectl get deployment secure-deployment
kubectl get pods -l app=secure-deployment
```

Execute into one of the pods and check the user ID:

```bash
POD_NAME=$(kubectl get pods -l app=secure-deployment -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD_NAME -- sh
whoami
id
exit
```

Note the user ID and group ID. They should be 1000.

### Step 6: Step 6: Cleanup

Clean up the resources created in this lab.

```bash
kubectl delete namespace security-context-lab
```


<details>
<summary> Hints (click to expand)</summary>

1. If the Pod fails to start after applying a Security Context, check the Kubernetes events for error messages.
2. Ensure the user and group IDs specified in the Security Context exist within the container image.
3. When dropping capabilities, be careful not to drop capabilities required for the application to function correctly.
4. If you're having trouble connecting to the cluster, double-check your `kubectl` configuration.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The solution involves creating Kubernetes Pods and Deployments with different Security Context configurations. By setting `runAsUser`, `runAsGroup`, and `capabilities`, you can control the security privileges of the containers running within the Pods. The key is to understand which privileges are necessary for the application to function and which can be safely dropped to minimize the attack surface.

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
