# Lab 32: Kubernetes: Local Persistent Volumes and Data Retention

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)

> **Auto-generated lab** - Created on 2025-12-31

## Description

Explore Kubernetes Persistent Volumes using local storage with `hostPath` and understand data retention strategies. This lab demonstrates how to configure a pod to use local storage, simulate a pod failure, and verify data persistence.

## Learning Objectives

- Understand the limitations of using `hostPath` for Persistent Volumes.
- Create a Persistent Volume (PV) and Persistent Volume Claim (PVC) using `hostPath`.
- Deploy a pod that utilizes the PVC.
- Simulate pod failure and verify data persistence.
- Clean up resources.

## Prerequisites

- A running Kubernetes cluster (minikube, Docker Desktop, or similar)
- kubectl installed and configured to connect to the cluster

## Lab Steps

### Step 1: Step 1: Create a Local Storage Directory

On the node where your pod will run, create a directory that will serve as the local storage for the Persistent Volume. If you are using minikube, you'll need to SSH into the minikube VM.

```bash
minikube ssh
sudo mkdir -p /data/my-app
sudo chown -R $(id -u):$(id -g) /data/my-app
exit
```

**Note:** Adjust the path `/data/my-app` and the ownership according to your environment.

### Step 2: Step 2: Define a Persistent Volume (PV)

Create a YAML file named `pv.yaml` to define a Persistent Volume that uses the `hostPath` provisioner.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /data/my-app
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - <YOUR_NODE_NAME>
```

Replace `<YOUR_NODE_NAME>` with the actual name of your Kubernetes node. You can find the node name using `kubectl get nodes`.  Apply the PV definition:

```bash
kubectl apply -f pv.yaml
```

### Step 3: Step 3: Define a Persistent Volume Claim (PVC)

Create a YAML file named `pvc.yaml` to define a Persistent Volume Claim that requests the storage defined in the PV.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc
spec:
  storageClassName: local-storage
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

Apply the PVC definition:

```bash
kubectl apply -f pvc.yaml
```

Verify that the PVC is bound to the PV:

```bash
kubectl get pvc
```

### Step 4: Step 4: Deploy a Pod using the PVC

Create a YAML file named `pod.yaml` to define a pod that uses the PVC to mount the persistent volume.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app-pod
spec:
  volumes:
    - name: my-data
      persistentVolumeClaim:
        claimName: local-pvc
  containers:
    - name: my-app-container
      image: busybox:latest
      command: ["/bin/sh", "-c", "while true; do echo $(date) >> /data/data.txt; sleep 5; done"]
      volumeMounts:
        - name: my-data
          mountPath: /data
```

Apply the Pod definition:

```bash
kubectl apply -f pod.yaml
```

Verify that the pod is running:

```bash
kubectl get pods
```

### Step 5: Step 5: Write Data to the Volume

The pod is configured to write the current date to a file named `data.txt` in the `/data` directory, which is mounted to the persistent volume.  Let the pod run for a few minutes to generate some data.

### Step 6: Step 6: Simulate Pod Failure and Verify Data Persistence

Delete the pod to simulate a failure:

```bash
kubectl delete pod my-app-pod
```

Now, re-create the pod using the same `pod.yaml` file:

```bash
kubectl apply -f pod.yaml
```

Once the pod is running again, check the contents of the `data.txt` file to verify that the data has persisted:

```bash
kubectl exec -it my-app-pod -- cat /data/data.txt
```

You should see the previously written data along with new entries.

### Step 7: Step 7: Cleanup

Delete all created resources:

```bash
kubectl delete pod my-app-pod
kubectl delete pvc local-pvc
kubectl delete pv local-pv
```

Optionally, remove the local storage directory on the node:

```bash
minikube ssh
sudo rm -rf /data/my-app
exit
```


<details>
<summary> Hints (click to expand)</summary>

1. Make sure the node name in the PV definition matches the actual node name in your cluster.
2. Ensure the storage class name in the PV and PVC definitions match.
3. If the PVC remains in a `Pending` state, check the PV's configuration and ensure that the `nodeAffinity` is correctly configured.
4. Double-check that the user running the pod has write permissions to the `hostPath` directory.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

This lab provides a basic understanding of using `hostPath` for local persistent volumes. While simple, it highlights the limitations of `hostPath`, such as manual node affinity configuration and lack of dynamic provisioning. Production environments often use more advanced solutions like dynamic provisioners (e.g., local-path-provisioner) or cloud provider storage solutions for persistent storage.

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
