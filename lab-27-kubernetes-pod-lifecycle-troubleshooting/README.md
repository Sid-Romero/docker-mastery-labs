# Lab 27: Kubernetes Pod Lifecycle: Deep Dive & Troubleshooting

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)

> **Auto-generated lab** - Created on 2025-12-30

## Description

Explore the Kubernetes pod lifecycle in detail. This lab covers pod creation, scheduling, container status, and common error scenarios, providing practical troubleshooting experience.

## Learning Objectives

- Understand the stages of the Kubernetes pod lifecycle.
- Identify common reasons for pod failures.
- Learn how to inspect pod events and logs for debugging.
- Practice techniques for resolving pod lifecycle issues.

## Prerequisites

- kubectl installed and configured to connect to a Kubernetes cluster (minikube, Docker Desktop, or a cloud provider cluster)
- Basic understanding of Kubernetes concepts (Pods, Deployments, Services)

## Lab Steps

### Step 1: Step 1: Create a Simple Pod

First, create a simple pod definition file named `pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: lifecycle-demo
  labels:
    app: lifecycle-demo
spec:
  containers:
  - name: lifecycle-demo-container
    image: nginx:latest
    ports:
    - containerPort: 80
```

Apply this configuration to your cluster:

```bash
kubectl apply -f pod.yaml
```

Verify the pod is created:

```bash
kubectl get pod lifecycle-demo
```

### Step 2: Step 2: Observe Pod Status Transitions

Use `kubectl describe pod lifecycle-demo` to examine the pod's status and events.  Pay attention to the 'Events' section.  Observe how the pod transitions through different states (Pending, Running).  What do the different events mean?

```bash
kubectl describe pod lifecycle-demo
```

### Step 3: Step 3: Introduce a Readiness Probe Failure

Modify the `pod.yaml` file to include a readiness probe that will initially fail.  Add the following `readinessProbe` to the container definition:

```yaml
    readinessProbe:
      httpGet:
        path: /nonexistent
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
```

Apply the updated configuration:

```bash
kubectl apply -f pod.yaml --force
```

Observe the pod status again.  What is the pod's status now?  Check the events. What do they say? What is the difference between `kubectl get pod` and `kubectl describe pod` output?

```bash
kubectl get pod lifecycle-demo
kubectl describe pod lifecycle-demo
```

### Step 4: Step 4: Introduce a Liveness Probe Failure (CrashLoopBackOff)

Now, let's introduce a liveness probe that will eventually cause the container to restart. Modify the `pod.yaml` file to include a liveness probe:

```yaml
    livenessProbe:
      exec:
        command: ['/bin/sh', '-c', 'exit 1']
      initialDelaySeconds: 15
      periodSeconds: 5
```

Apply the updated configuration:

```bash
kubectl apply -f pod.yaml --force
```

Observe the pod status. You should see the pod enter a `CrashLoopBackOff` state. Examine the events to understand why. What does `CrashLoopBackOff` mean? How is it different from the previous readiness probe failure?

```bash
kubectl get pod lifecycle-demo
kubectl describe pod lifecycle-demo
```

### Step 5: Step 5: Investigate Pod Logs

Even though the pod is crashing, you can still inspect its logs (if any exist before the crash). Use the following command:

```bash
kubectl logs lifecycle-demo
```

In this case, the logs may be empty because the container is failing immediately. However, in real-world scenarios, logs are crucial for debugging.

Modify the liveness probe to sleep for a few seconds before exiting to generate some logs:

```yaml
    livenessProbe:
      exec:
        command: ['/bin/sh', '-c', 'sleep 5; exit 1']
      initialDelaySeconds: 15
      periodSeconds: 5
```

Apply the changes and check the logs again. You should now see some output.

```bash
kubectl apply -f pod.yaml --force
kubectl logs lifecycle-demo
```

### Step 6: Step 6: Cleanup

Delete the pod to clean up the environment:

```bash
kubectl delete pod lifecycle-demo
```


<details>
<summary> Hints (click to expand)</summary>

1. Use `kubectl get pod <pod-name> -o yaml` to see the full pod definition.
2. Pay close attention to the 'Events' section in `kubectl describe pod <pod-name>` for debugging information.
3. The `--force` flag is sometimes needed to update a pod definition in place, especially with probes.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The solution involves creating a pod, observing its lifecycle states, and then intentionally introducing failures through readiness and liveness probes.  The key is to use `kubectl describe` and `kubectl logs` to understand the reasons for the failures and the pod's state transitions.  Understanding the difference between readiness and liveness probes is crucial.

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
