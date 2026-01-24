# Lab 70: Kubernetes: Let's Encrypt with cert-manager

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)

> **Auto-generated lab** - Created on 2026-01-24

## Description

This lab guides you through setting up cert-manager in a Kubernetes cluster to automatically obtain and renew SSL certificates from Let's Encrypt. It focuses on using a simple HTTP-01 challenge for validation, suitable for local testing.

## Learning Objectives

- Install and configure cert-manager in a Kubernetes cluster
- Create an Issuer to obtain certificates from Let's Encrypt
- Deploy a simple application and expose it with an Ingress
- Automatically provision SSL certificates for the Ingress using cert-manager

## Prerequisites

- A running Kubernetes cluster (minikube, Docker Desktop, etc.)
- kubectl installed and configured
- helm installed (optional, but recommended)

## Lab Steps

### Step 1: Install cert-manager

First, add the Jetstack Helm repository:

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
```

Next, install the cert-manager CRDs. This is crucial before installing the cert-manager chart itself:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml
```

Finally, install cert-manager using Helm.  Make sure to specify the namespace `cert-manager`:

```bash
helm install
  cert-manager jetstack/cert-manager
  --namespace cert-manager
  --create-namespace
  --version v1.13.2
  --set installCRDs=true
```

Verify that cert-manager is running correctly by checking the status of the deployments in the `cert-manager` namespace:

```bash
kubectl get deployments -n cert-manager
```

All deployments should be in the `READY` state.

### Step 2: Create a Let's Encrypt Issuer

Create a file named `issuer.yaml` with the following content.  **Important:** Replace `your-email@example.com` with a valid email address. This is required by Let's Encrypt.

```yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    email: your-email@example.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: nginx
```

Apply the `issuer.yaml` file to your cluster:

```bash
kubectl apply -f issuer.yaml
```

Verify the Issuer is created:

```bash
kubectl get issuer letsencrypt-staging
```

**Note:** This Issuer uses the Let's Encrypt staging environment. Certificates issued by the staging environment are not trusted by browsers, but they are useful for testing without hitting rate limits. For production, you'll need to create a similar Issuer that points to the production Let's Encrypt endpoint.  Replace `https://acme-staging-v02.api.letsencrypt.org/directory` with `https://acme-v02.api.letsencrypt.org/directory` and change the issuer name accordingly (e.g., `letsencrypt-prod`).

### Step 3: Deploy a Simple Application

Create a simple deployment and service. Create a file named `app.yaml` with the following content:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world
spec:
  selector:
    matchLabels:
      app: hello-world
  replicas: 1
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-world
        image: nginx:latest
        ports:
        - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: hello-world-service
spec:
  selector:
    app: hello-world
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

Apply the `app.yaml` file to your cluster:

```bash
kubectl apply -f app.yaml
```

Verify that the deployment and service are running:

```bash
kubectl get deployments
kubectl get services
```

### Step 4: Create an Ingress Resource

Create an Ingress resource to expose the application. Create a file named `ingress.yaml` with the following content.  **Important:** Replace `your-domain.example.com` with a domain name you control or a hostname you can resolve to your cluster's IP address (e.g., using `/etc/hosts` for minikube).

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-world-ingress
  annotations:
    cert-manager.io/issuer: letsencrypt-staging
spec:
  rules:
  - host: your-domain.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: hello-world-service
            port:
              number: 80
  tls:
  - hosts:
    - your-domain.example.com
    secretName: hello-world-tls
```

Apply the `ingress.yaml` file to your cluster:

```bash
kubectl apply -f ingress.yaml
```

Verify that the Ingress is created:

```bash
kubectl get ingress
```

**Note:** The `cert-manager.io/issuer: letsencrypt-staging` annotation tells cert-manager to automatically obtain a certificate for the specified host using the `letsencrypt-staging` Issuer. The `tls` section specifies the host and the name of the secret where the certificate will be stored (`hello-world-tls`).

### Step 5: Verify Certificate Issuance

Check the status of the Certificate resource. Cert-manager automatically creates a Certificate resource based on the Ingress.

```bash
kubectl get certificate
```

If the certificate is not ready, you can check the events for the Certificate resource to see what's happening:

```bash
kubectl describe certificate hello-world-tls
```

It may take a few minutes for the certificate to be issued. Once the certificate is issued, you can access your application using the specified domain name (e.g., `your-domain.example.com`) in your browser.  Because you are using the staging environment, your browser will likely show a warning about an untrusted certificate. This is expected.

To test with minikube, add an entry to your `/etc/hosts` file that maps your domain to the minikube IP address. You can find the minikube IP address by running `minikube ip`.

For example:

```
192.168.64.3 your-domain.example.com
```


<details>
<summary> Hints (click to expand)</summary>

1. Ensure the cert-manager pods are running correctly before proceeding.
2. Double-check the email address in the Issuer configuration.
3. Make sure your domain name or hostname is correctly configured and resolves to your cluster's IP address. Use `/etc/hosts` for local testing with minikube.
4. If the certificate issuance fails, examine the events for the Certificate resource using `kubectl describe certificate <certificate-name>`.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The lab demonstrates the basic setup of cert-manager with Let's Encrypt using HTTP-01 challenge. For production environments, consider using DNS-01 challenge for more reliable certificate issuance, especially when dealing with wildcard certificates or multiple subdomains.  Remember to switch to the production Let's Encrypt endpoint when you are ready to deploy your application to production.

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
