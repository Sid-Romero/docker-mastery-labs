# Lab 35: Kubernetes Horizontal Pod Autoscaling (HPA)

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)

> **Auto-generated lab** - Created on 2026-01-01

## Description

This lab demonstrates how to configure Horizontal Pod Autoscaling (HPA) in Kubernetes to automatically scale the number of pods in a deployment based on CPU utilization. We will deploy a sample application and configure HPA to increase or decrease the number of pods based on CPU load.

## Learning Objectives

- Understand the concept of Horizontal Pod Autoscaling (HPA)
- Deploy a sample application to Kubernetes
- Configure HPA to scale deployments based on CPU utilization
- Observe HPA in action and verify scaling behavior

## Prerequisites

- kubectl installed and configured to connect to a Kubernetes cluster (minikube, Docker Desktop, or a cloud provider cluster)
- Basic understanding of Kubernetes deployments and services

## Lab Steps

### Step 1: Step 1: Deploy a Sample Application

First, we'll deploy a simple application that consumes CPU. Create a `deployment.yaml` file with the following content:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cpu-consumer
spec:
  selector:
    matchLabels:
      app: cpu-consumer
  replicas: 1
  template:
    metadata:
      labels:
        app: cpu-consumer
    spec:
      containers:
      - name: cpu-consumer
        image: busybox:latest
        command: ['sh', '-c', 'while true; do dd if=/dev/zero of=/dev/null bs=1M count=100; done']
        resources:
          limits:
            cpu: "500m"
          requests:
            cpu: "200m"
```

Apply the deployment:

```bash
kubectl apply -f deployment.yaml
```

Next, create a `service.yaml` file to expose the application.  Since this app does not expose any ports, this service is not strictly required for HPA to function, but it's good practice to have a service for any deployent.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: cpu-consumer
spec:
  selector:
    app: cpu-consumer
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
```

Apply the service:

```bash
kubectl apply -f service.yaml
```

Verify that the deployment and service are running:

```bash
kubectl get deployments
kubectl get services
```

### Step 2: Step 2: Create a Horizontal Pod Autoscaler (HPA)

Now, we will create an HPA that targets the `cpu-consumer` deployment and scales it based on CPU utilization.  Create an `hpa.yaml` file with the following content:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: cpu-consumer-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: cpu-consumer
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

This HPA configuration will maintain between 1 and 5 replicas of the `cpu-consumer` deployment. It will increase the number of replicas if the average CPU utilization across all pods exceeds 50%, and decrease the number of replicas if the CPU utilization falls below 50%.

Apply the HPA:

```bash
kubectl apply -f hpa.yaml
```

Verify that the HPA has been created:

```bash
kubectl get hpa
```

### Step 3: Step 3: Generate Load and Observe Scaling

To trigger the HPA, we need to generate some load on the `cpu-consumer` deployment. We can do this by running a command inside a pod that sends requests to the service.  Because the `cpu-consumer` deployment does not actually serve requests, we need to create a new pod that just generates load.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: load-generator
spec:
  containers:
  - name: load-generator
    image: busybox:latest
    command: ['sh', '-c', 'while true; do wget -q -O- http://cpu-consumer; done']
```

Apply the pod:

```bash
kubectl apply -f load-generator.yaml
```

Now, observe the HPA and the number of pods in the deployment:

```bash
kubectl get hpa cpu-consumer-hpa --watch
kubectl get deployments cpu-consumer --watch
```

You should see the HPA start to scale up the number of pods in the `cpu-consumer` deployment as the CPU utilization increases.  The `load-generator` pod keeps the CPU busy.

To stop the load generation and observe the scale down, delete the `load-generator` pod:

```bash
kubectl delete pod load-generator
```

Observe the HPA again to see the scale down.

```bash
kubectl get hpa cpu-consumer-hpa --watch
kubectl get deployments cpu-consumer --watch
```

### Step 4: Step 4: Cleanup

To clean up the resources created in this lab, run the following commands:

```bash
kubectl delete hpa cpu-consumer-hpa
kubectl delete service cpu-consumer
kubectl delete deployment cpu-consumer
```


<details>
<summary> Hints (click to expand)</summary>

1. Ensure that the resource requests and limits are properly configured for the `cpu-consumer` container. If not the HPA may not scale correctly.
2. If the HPA is not scaling, check the HPA's status using `kubectl describe hpa cpu-consumer-hpa` to identify any errors.
3. Make sure the metrics server is running in your cluster.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The solution involves deploying a CPU-intensive application, configuring an HPA to monitor CPU utilization, and generating load to trigger the autoscaling.  The key is to observe the HPA scaling the number of pods in response to the increased CPU load. After removing the load, the HPA will scale down the number of pods to the minimum specified in the HPA configuration.

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
