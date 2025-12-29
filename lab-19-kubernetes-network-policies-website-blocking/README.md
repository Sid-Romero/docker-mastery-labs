# Lab 19: Kubernetes Network Policies: Website Blocking Simulation

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)

> **Auto-generated lab** - Created on 2025-12-29

## Description

This lab simulates a simplified version of website blocking using Kubernetes Network Policies. You'll deploy a simple web application and then use Network Policies to restrict access to it, mimicking how ISPs might block access to specific websites based on government mandates.

## Learning Objectives

- Understand the basics of Kubernetes Network Policies.
- Learn how to apply Network Policies to control network traffic within a Kubernetes cluster.
- Simulate website blocking by restricting access to a web application.
- Observe the effects of Network Policies on pod-to-pod communication.

## Prerequisites

- A running Kubernetes cluster (e.g., minikube, Docker Desktop with Kubernetes enabled).
- kubectl installed and configured to connect to your cluster.
- Basic understanding of Kubernetes concepts (Pods, Deployments, Services).

## Lab Steps

### Step 1: Step 1: Deploy a Sample Web Application

First, deploy a simple web application to serve as our 'website'. Create a `deployment.yaml` file with the following content:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: nginx:latest
        ports:
        - containerPort: 80
```

Apply the deployment:

```bash
kubectl apply -f deployment.yaml
```

Verify the deployment is running:

```bash
kubectl get deployments
```

Next, create a `service.yaml` file to expose the web application:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
spec:
  selector:
    app: web-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: NodePort
```

Apply the service:

```bash
kubectl apply -f service.yaml
```

Verify the service is running:

```bash
kubectl get services
```

Find the NodePort assigned to the service:

```bash
kubectl describe service web-app-service
```

Access the web application in your browser using the NodePort and your cluster's IP address (e.g., `minikube service web-app-service --url`). You should see the default nginx welcome page.

### Step 2: Step 2: Deploy a Client Pod to Test Connectivity

Now, deploy a client pod that we'll use to test connectivity to the web application. Create a `client.yaml` file:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: client
spec:
  containers:
  - name: client
    image: curlimages/curl:latest
    command: ["sleep", "3600"]
```

Apply the pod:

```bash
kubectl apply -f client.yaml
```

Verify the pod is running:

```bash
kubectl get pods
```

Exec into the client pod:

```bash
kubectl exec -it client -- bash
```

From inside the client pod, use `curl` to access the web application service. You'll need the service's cluster IP. Find the cluster IP using:

```bash
kubectl get service web-app-service -o wide
```

Then, use `curl` with the cluster IP and port 80:

```bash
curl <cluster-ip>:80
```

You should see the HTML content of the nginx welcome page. This confirms the client pod can access the web application.

### Step 3: Step 3: Implement a Network Policy to Block Access

Now, create a Network Policy to simulate blocking access to the web application. Create a `network-policy.yaml` file. This policy will deny all ingress traffic to pods with the label `app: web-app` from pods that *do not* have the label `access: allowed`. 

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: block-web-app
spec:
  podSelector:
    matchLabels:
      app: web-app
  ingress:
  - from:
    - podSelector:
        matchLabels:
          access: allowed
```

Apply the Network Policy:

```bash
kubectl apply -f network-policy.yaml
```

Now, return to the client pod's shell (if you exited, execute `kubectl exec -it client -- bash` again) and try to `curl` the web application service again:

```bash
curl <cluster-ip>:80
```

You should find that the request times out. This is because the Network Policy is blocking traffic from the client pod (which doesn't have label `access: allowed`) to the web application pods. 

**Important:** Network Policies are additive. If no policy exists, all traffic is allowed. If any policy exists, traffic is implicitly denied unless explicitly allowed.

### Step 4: Step 4: Allow Access from a Specific Pod

To demonstrate allowing access, label the client pod with `access: allowed`:

```bash
kubectl label pod client access=allowed
```

Wait a few seconds for the changes to propagate. Now, go back into the client pod:

```bash
kubectl exec -it client -- bash
```

And try to `curl` the web application service again:

```bash
curl <cluster-ip>:80
```

You should now see the HTML content of the nginx welcome page again. This is because the Network Policy now allows traffic from pods with the `access: allowed` label.

### Step 5: Step 5: Cleanup

To clean up the resources created in this lab, run the following commands:

```bash
kubectl delete networkpolicy block-web-app
kubectl delete service web-app-service
kubectl delete deployment web-app
kubectl delete pod client
```


<details>
<summary> Hints (click to expand)</summary>

1. Make sure your Kubernetes cluster has a Network Policy controller enabled (e.g., Calico, Cilium, Weave Net).
2. If you are having trouble accessing the service, double-check the NodePort and ClusterIP are correct.
3. Remember to apply the network policy *after* deploying the web application and client pod.
4. Network policies are additive; the default behavior is to allow all traffic if no policies are defined.
5. The ingress section defines what is allowed into the selected pods.
6. The `podSelector` in the ingress `from` section specifies which pods are allowed to send traffic to the selected pods.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The solution involves deploying a simple Nginx web application, a client pod for testing connectivity, and a Network Policy that initially blocks all traffic to the web application from the client pod.  The client pod is then labeled to allow traffic based on the Network Policy's 'from' selector.

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
