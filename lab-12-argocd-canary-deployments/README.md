# Lab 12: ArgoCD: Progressive Rollouts with Canary Deployments

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?logo=argo&logoColor=white)

> **Auto-generated lab** - Created on 2025-12-28

## Description

This lab explores using ArgoCD to manage progressive rollouts with canary deployments. You'll deploy a simple application and then update it using ArgoCD's declarative configuration and canary strategies to minimize risk during updates.

## Learning Objectives

- Install and configure ArgoCD in a Kubernetes cluster.
- Deploy an application using ArgoCD.
- Implement a canary deployment strategy using ArgoCD.
- Verify and promote the canary deployment.
- Understand ArgoCD's rollback capabilities.

## Prerequisites

- kubectl installed and configured to connect to a Kubernetes cluster (minikube, Docker Desktop, or a cloud provider cluster).
- Helm installed.
- ArgoCD CLI installed (https://argo-cd.readthedocs.io/en/stable/cli_installation/)
- Basic understanding of Kubernetes deployments and services.

## Lab Steps

### Step 1: Install ArgoCD

First, create a namespace for ArgoCD:

```bash
kubectl create namespace argocd
```

Then, apply the ArgoCD installation manifests:

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Wait for all ArgoCD pods to be running before proceeding. You can check the status with:

```bash
kubectl get pods -n argocd
```

Finally, retrieve the initial ArgoCD admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
```

Store this password securely.  You will use it to log in to the ArgoCD UI.


### Step 2: Access the ArgoCD UI

To access the ArgoCD UI, you can use port forwarding:

```bash
kubectl port-forward svc/argo-cd-server -n argocd 8080:443
```

Open your web browser and navigate to `https://localhost:8080`. You may need to accept a self-signed certificate warning. Log in with the username `admin` and the password you retrieved in the previous step. Alternatively, you can expose the ArgoCD server using an ingress or LoadBalancer service in a real environment.

### Step 3: Deploy a Sample Application

Create a new directory for your application configuration:

```bash
mkdir argocd-canary-demo
cd argocd-canary-demo
```

Create a `deployment.yaml` file with the following content:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  labels:
    app: my-app
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
        image: nginx:1.20
        ports:
        - containerPort: 80
```

Create a `service.yaml` file with the following content:

```yaml
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

(Note: `LoadBalancer` type might not work in minikube without extra configuration, consider using `NodePort` instead and access it via `minikube service my-app-service`)

Commit these files to a Git repository (e.g., GitHub, GitLab, Bitbucket). This repository will be the source of truth for ArgoCD.


### Step 4: Create an ArgoCD Application

In the ArgoCD UI, click "+ New App". Fill in the following details:

*   **Application Name:** `my-app`
*   **Project:** `default`
*   **Sync Policy:** `Automatic` (select `Prune` and `Self Heal`)
*   **Repository URL:** Your Git repository URL containing the `deployment.yaml` and `service.yaml` files.
*   **Revision:** `HEAD` (or the branch you are using, e.g., `main`)
*   **Path:** `.` (the root directory of your repository)
*   **Cluster URL:** `https://kubernetes.default.svc`
*   **Namespace:** `default` (or any other namespace you prefer)

Click "Create". ArgoCD will now deploy your application.  Observe the application status in the ArgoCD UI.  It should eventually show as `Synced` and `Healthy`.


### Step 5: Implement a Canary Deployment

Modify the `deployment.yaml` file in your Git repository to create a canary deployment.  Add a new label and update the image version:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  labels:
    app: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
        version: v2  # Add this label
    spec:
      containers:
      - name: my-app
        image: nginx:1.21  # Update the image version
        ports:
        - containerPort: 80
```

Now, create a second deployment file named `deployment-canary.yaml` with the following content. This file will define the canary deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-canary
  labels:
    app: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
      version: v2  # Match the new label
  template:
    metadata:
      labels:
        app: my-app
        version: v2  # Add this label
    spec:
      containers:
      - name: my-app
        image: nginx:1.21  # Update the image version
        ports:
        - containerPort: 80
```
Commit both changes to your Git repository.


### Step 6: Update the ArgoCD Application

In the ArgoCD UI, navigate to your `my-app` application.  You will see that ArgoCD detects the changes in your Git repository. It may show as `OutOfSync`.
ArgoCD needs to deploy both deployments. 
Click the "Sync" button. ArgoCD will now deploy the canary deployment alongside the original deployment.  You should now have two deployments running: `my-app` (with the old version) and `my-app-canary` (with the new version).

**Important**: Your Service needs to target pods with `app: my-app` label. This way the load will be distributed between old and canary deployment.


### Step 7: Verify the Canary Deployment

Verify that the canary deployment is working correctly. You can use `kubectl get pods` to see the running pods and their versions. You'll need to access your application via the service (e.g., using `kubectl port-forward` or the external IP if you're using a LoadBalancer).

To verify the canary is receiving traffic, you can inspect the logs of both deployments. Since the current setup uses `nginx`, you'd need to configure logging to differentiate requests or temporarily add a custom header to the canary deployment's responses.

In a real-world scenario, you would use metrics, monitoring tools, and A/B testing to evaluate the performance and stability of the canary deployment.


### Step 8: Promote or Rollback

If the canary deployment is successful, you can promote it by updating the original `deployment.yaml` to use the new image version and removing the `deployment-canary.yaml` file. Commit these changes to your Git repository and ArgoCD will automatically update the main deployment.

If the canary deployment is unsuccessful, you can rollback by reverting the changes in your Git repository. ArgoCD will automatically revert the deployments to the previous state. To rollback, you can either use `git revert` command or use ArgoCD's history and rollback functionality.



<details>
<summary> Hints (click to expand)</summary>

1. Make sure your Git repository is accessible to ArgoCD.
2. Double-check the labels and selectors in your deployment and service configurations.
3. When using minikube, you might need to use NodePort instead of LoadBalancer for the service type.
4. If ArgoCD is not syncing, check the application events for errors.
5. Ensure your canary deployment's labels match the service's selector to receive traffic.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The complete solution involves configuring ArgoCD to monitor a Git repository containing Kubernetes manifests for a simple application. A canary deployment is implemented by creating a separate deployment manifest with a different image version and a specific label. The service is configured to route traffic to both the original and canary deployments based on a common app label. By modifying the deployment manifests and using ArgoCD's automatic synchronization, the lab demonstrates a controlled rollout of a new application version and the ability to rollback if issues are detected.

</details>


---

## Notes

- **Difficulty:** Medium
- **Estimated time:** 45-75 minutes
- **Technology:** Argocd

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
