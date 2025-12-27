# Lab 11: ArgoCD: Preventing Secret Exposure with GitOps

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?logo=argo&logoColor=white)

> **Auto-generated lab** - Created on 2025-12-27

## Description

This lab demonstrates how ArgoCD can be used to manage Kubernetes secrets securely and prevent accidental exposure of sensitive data by enforcing GitOps principles and utilizing Kustomize for secret management. It focuses on a scenario where a developer mistakenly commits a secret to a public repository and how ArgoCD helps mitigate the risk.

## Learning Objectives

- Set up ArgoCD in a Kubernetes cluster.
- Create an ArgoCD application to manage a Kubernetes deployment.
- Simulate accidental secret exposure by committing a secret to a Git repository.
- Implement Kustomize to manage secrets and prevent them from being stored directly in the repository.
- Observe how ArgoCD detects and reverts changes to the deployed application based on the Git repository state.

## Prerequisites

- kubectl installed and configured to connect to a Kubernetes cluster (minikube, Docker Desktop, or similar)
- Helm installed
- Git installed
- ArgoCD CLI installed (https://argo-cd.readthedocs.io/en/stable/cli_installation/)
- Basic understanding of Kubernetes deployments, services, and secrets
- Basic understanding of GitOps principles

## Lab Steps

### Step 1: Install ArgoCD

First, create a namespace for ArgoCD and install it using Helm.

```bash
kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd
```

After installation, access the ArgoCD UI.  By default, it's not exposed.  You can use port forwarding to access it locally:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open your browser and navigate to `https://localhost:8080`.  The default username is `admin`. Retrieve the initial password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Log in to the ArgoCD UI with the username `admin` and the retrieved password.  Change the password after logging in for the first time.

### Step 2: Create a Sample Application Repository

Create a new Git repository (e.g., on GitHub, GitLab, or locally). This repository will hold the Kubernetes manifests for our sample application. Initialize the repository with a basic deployment, service, and a naive secret.

```bash
mkdir argocd-secret-demo
cd argocd-secret-demo
git init
```

Create the following files:

`deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  selector:
    matchLabels:
      app: my-app
  replicas: 1
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: nginx:latest
        ports:
        - containerPort: 80
        env:
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: my-secret
              key: api-key
```

`service.yaml`:

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

`secret.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  api-key: $(echo 'this-is-a-very-secret-api-key' | base64)
```

Commit and push these files to your Git repository.

```bash
git add .
git commit -m "Initial commit with deployment, service, and secret"
git remote add origin <your_git_repository_url>
git push -u origin main
```

**Note:** Replace `<your_git_repository_url>` with the actual URL of your Git repository.

### Step 3: Create an ArgoCD Application

Now, create an ArgoCD application that points to your Git repository. You can do this through the ArgoCD UI or using the ArgoCD CLI.

**Using the ArgoCD CLI:**

```bash
argocd app create my-app \
  --repo <your_git_repository_url> \
  --path . \
  --dest-namespace default \
  --dest-server https://kubernetes.default.svc \
  --sync-policy automated
```

**Note:** Replace `<your_git_repository_url>` with the actual URL of your Git repository.  `--sync-policy automated` enables automatic synchronization and self-healing.

After creating the application, ArgoCD will automatically deploy the resources defined in your Git repository to the cluster. Verify that the deployment, service, and secret are created and running.

```bash
kubectl get deployment,service,secret
```

### Step 4: Simulate Secret Exposure (Accidental Commit)

Let's simulate a scenario where a developer accidentally modifies the secret and commits the change to the Git repository. Edit the `secret.yaml` file and change the `api-key` value. For example:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  api-key: $(echo 'this-is-a-new-very-secret-api-key' | base64)
```

Commit and push the change to the Git repository:

```bash
git commit -am "Accidentally updated secret"
git push origin main
```

Observe how ArgoCD detects the change in the Git repository and automatically synchronizes the application. The secret in the cluster will be updated with the new (exposed) value.  This is the problem we want to solve.

### Step 5: Implement Kustomize for Secret Management

To prevent secrets from being stored directly in the Git repository, we will use Kustomize to manage them. First, remove the `secret.yaml` file from the repository:

```bash
git rm secret.yaml
git commit -m "Remove secret.yaml"
git push origin main
```

Create a `kustomization.yaml` file in the repository root:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml

generators:
  - type: Opaque
    name: my-secret
    literals:
      - api-key=REDACTED
```

Update the ArgoCD application to point to the Kustomize directory. You can do this through the ArgoCD UI or using the ArgoCD CLI:

**Using the ArgoCD CLI:**

```bash
argocd app edit my-app --path .
```

ArgoCD will now use Kustomize to generate the secret during deployment.  The `REDACTED` value is a placeholder and will **not** be used.  We are preventing the real secret from being committed to the repo.  The actual secret needs to be injected some other way.  This is outside the scope of this lab, but could include HashiCorp Vault, AWS Secrets Manager, etc.

Commit and push the changes to the Git repository:

```bash
git add kustomization.yaml
git commit -m "Implement Kustomize for secret management"
git push origin main
```

Verify that ArgoCD synchronizes the application and the deployment and service are still running.

### Step 6: Verify Secret Management and Prevention of Exposure

Now, try to modify the `api-key` value in the `kustomization.yaml` file and commit the change to the Git repository:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml

generators:
  - type: Opaque
    name: my-secret
    literals:
      - api-key=ANOTHER_REDACTED_VALUE
```

```bash
git commit -am "Attempt to update secret in kustomization.yaml"
git push origin main
```
ArgoCD will detect the change, but the deployed secret will still contain the original (or whatever value injected from external secret store) because Kustomize is generating the secret based on the `literals` field. While this example uses a static placeholder, the key takeaway is that the *actual* secret value is not stored directly in the Git repository.  This is a critical step towards preventing accidental secret exposure.

To fully implement a robust solution, you would integrate with an external secret management system (e.g., HashiCorp Vault, AWS Secrets Manager) and use Kustomize to reference secrets from that system during deployment.  This lab provides the foundation for that approach by demonstrating how to prevent secrets from being committed to the repository and managed through GitOps.


<details>
<summary> Hints (click to expand)</summary>

1. Make sure your Git repository is accessible to ArgoCD.
2. Double-check the ArgoCD application path and destination namespace.
3. Use a strong password for the ArgoCD admin user.
4. Remember to commit and push your changes to the Git repository after each modification.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The key to preventing secret exposure is to avoid storing secrets directly in the Git repository. This lab demonstrates how Kustomize can be used to generate secrets during deployment, allowing you to reference secrets from external secret management systems. By enforcing GitOps principles with ArgoCD, you can ensure that any accidental changes to secrets in the Git repository are automatically reverted, mitigating the risk of exposure.

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
