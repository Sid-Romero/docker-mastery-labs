# Lab 08: Kubernetes: Geo-Aware Pod Placement

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)

> **Auto-generated lab** - Created on 2025-12-27

## Description

This lab explores how to leverage Kubernetes node affinity and taints/tolerations to influence pod placement based on simulated geographical regions.  We'll simulate different regions and ensure our applications are deployed in the correct 'location'. This demonstrates a key component of building applications that minimize perceived latency by deploying close to users.

## Learning Objectives

- Understand Kubernetes node affinity and its role in pod scheduling.
- Learn how to use node labels to represent geographical regions.
- Implement node affinity rules to ensure pods are deployed in specific regions.
- Explore taints and tolerations to prevent pods from being scheduled on specific nodes (or require specific conditions).

## Prerequisites

- A running Kubernetes cluster (minikube, Docker Desktop, or similar)
- kubectl installed and configured to connect to your cluster
- Basic understanding of Kubernetes concepts like pods, nodes, and deployments

## Lab Steps

### Step 1: Step 1: Labeling Nodes to Simulate Regions

First, we'll simulate different geographical regions by labeling our Kubernetes nodes.  Identify the names of your nodes using `kubectl get nodes`. Then, apply labels to represent different regions.  For example, to label a node as being in 'us-east-1', use the following command, replacing `<node_name>` with the actual name of one of your nodes. Repeat this for other nodes, using different region labels (e.g., `us-west-2`, `eu-central-1`).

```bash
kubectl label node <node_name> topology.kubernetes.io/region=us-east-1
```

Verify the labels have been applied using `kubectl get nodes --show-labels`.

### Step 2: Step 2: Creating a Deployment with Node Affinity

Now, create a deployment that uses node affinity to ensure pods are scheduled in a specific region.  Create a `deployment.yaml` file with the following content.  This example will schedule pods in the `us-east-1` region.  Adjust the `matchExpressions` value to target other regions.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: geo-aware-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: geo-aware-app
  template:
    metadata:
      labels:
        app: geo-aware-app
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: topology.kubernetes.io/region
                operator: In
                values:
                - us-east-1
      containers:
      - name: geo-aware-app
        image: nginx:latest
        ports:
        - containerPort: 80
```

Apply the deployment using `kubectl apply -f deployment.yaml`.

### Step 3: Step 3: Verifying Pod Placement

Check where the pods have been scheduled using `kubectl get pods -o wide`. The `NODE` column will show which node each pod is running on. Verify that the pods are running on nodes labeled with the `us-east-1` region.  If not, review your node labels and deployment configuration.

If pods are pending, it likely means there are no nodes that match the affinity rules. Ensure at least one node has the correct label.

### Step 4: Step 4: Introducing Taints and Tolerations

Taints allow you to mark nodes as undesirable for certain pods, unless those pods have a matching toleration.  Let's taint one of our nodes to simulate a node that should only be used by specific applications.  Taint a node using the following command, replacing `<node_name>` with the name of a node.

```bash
kubectl taint nodes <node_name> dedicated=special-app:NoSchedule
```

This taint means that no pods will be scheduled on this node unless they have a toleration for `dedicated=special-app:NoSchedule`. Modify your `deployment.yaml` to include a toleration:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: geo-aware-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: geo-aware-app
  template:
    metadata:
      labels:
        app: geo-aware-app
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: topology.kubernetes.io/region
                operator: In
                values:
                - us-east-1
      tolerations:
      - key: "dedicated"
        operator: "Equal"
        value: "special-app"
        effect: "NoSchedule"
      containers:
      - name: geo-aware-app
        image: nginx:latest
        ports:
        - containerPort: 80
```

Apply the updated deployment and observe how the toleration affects pod placement. Some pods *may* now be scheduled on the tainted node, if it also matches the affinity rules.

### Step 5: Step 5: Experiment and Observe

Experiment with different affinity rules, tolerations, and taints. Try the following:

*   Create a second deployment targeting a different region.
*   Add a `preferredDuringSchedulingIgnoredDuringExecution` affinity rule instead of `requiredDuringSchedulingIgnoredDuringExecution` and observe the behavior.
*   Use different taint effects (`NoExecute`, `PreferNoSchedule`).

Observe how these changes impact pod placement. Consider scenarios where certain nodes are more expensive or have special hardware, and how taints/tolerations can be used to manage resource allocation.


<details>
<summary> Hints (click to expand)</summary>

1. If pods are stuck in a `Pending` state, double-check your node labels and affinity rules.
2. Ensure that at least one node in your cluster has the labels specified in your node affinity rules.
3. Tolerations must match the taint's key, value, and effect exactly for a pod to be scheduled on a tainted node.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The solution involves correctly labeling nodes to represent different geographical regions and configuring deployments with appropriate node affinity rules and tolerations. The key is to ensure that the affinity rules and tolerations match the node labels and taints, respectively. Careful observation of pod placement is crucial to verify the configuration.

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
