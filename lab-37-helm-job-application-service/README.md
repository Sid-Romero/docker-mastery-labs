# Lab 37: Helm Chart for a Simple Job Application Service

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Helm](https://img.shields.io/badge/Helm-0F1689?logo=helm&logoColor=white)

> **Auto-generated lab** - Created on 2026-01-01

## Description

This lab guides you through creating a Helm chart for deploying a simple job application service on Kubernetes. You will learn how to structure a chart, define values, and use templates to customize deployments.

## Learning Objectives

- Create a basic Helm chart structure.
- Define configurable values for a deployment.
- Use Helm templates to generate Kubernetes manifests.
- Deploy and test the Helm chart on a local Kubernetes cluster.

## Prerequisites

- kubectl installed and configured to connect to a Kubernetes cluster (e.g., minikube, Docker Desktop)
- Helm installed (version 3 or later)
- Basic understanding of Kubernetes deployments and services

## Lab Steps

### Step 1: Create a Helm Chart

Use the `helm create` command to generate a new Helm chart named `job-app`. This will create a directory structure with the necessary files for your chart.

```bash
helm create job-app
cd job-app
```

Inspect the generated files, particularly `Chart.yaml`, `values.yaml`, and the `templates/` directory.

### Step 2: Define the Application Deployment

Replace the contents of `templates/deployment.yaml` with the following. This defines a simple deployment for a hypothetical job application service.  We'll use a placeholder image `nginx:latest` for now.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "job-app.fullname" . }}
  labels:
    {{- include "job-app.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "job-app.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "job-app.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "job-app.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 5
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 5
            periodSeconds: 10
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}


### Step 3: Define the Service

Replace the contents of `templates/service.yaml` with the following to expose the deployment.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "job-app.fullname" . }}
  labels:
    {{- include "job-app.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
      protocol: TCP
      name: http
  selector:
    {{- include "job-app.selectorLabels" . | nindent 4 }}
```

### Step 4: Configure Values

Modify the `values.yaml` file to customize the deployment.  Change the `replicaCount`, `image.repository`, and `service.type` to the following.  Leave the other values as their defaults.

```yaml
replicaCount: 2

image:
  repository: nginx
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: "latest"

service:
  type: LoadBalancer
  port: 80
```

Note: If you are using minikube, using `LoadBalancer` as the service type will require you to run `minikube tunnel` in a separate terminal to access the service.

### Step 5: Install the Chart

Install the Helm chart into your Kubernetes cluster.  Use a release name of `my-job-app`.

```bash
helm install my-job-app .
```

Verify that the deployment and service are created successfully using `kubectl get deployments` and `kubectl get services`.

### Step 6: Test the Application

If you are using `LoadBalancer` service type, get the external IP address of the service using `kubectl get service my-job-app`.  If you are using minikube and have `minikube tunnel` running, the IP will be `127.0.0.1`. Access the application in your browser using the external IP and the port defined in `values.yaml` (port 80 in this case).

If you are using `ClusterIP` service type, you can use port forwarding to access the application.

```bash
kubectl port-forward service/my-job-app 8080:80
```

Then access the application in your browser at `http://localhost:8080`.

### Step 7: Upgrade the Chart

Modify the `values.yaml` file again, changing the `replicaCount` to 3.  Then, upgrade the Helm release.

```bash
helm upgrade my-job-app .
```

Verify that the number of replicas in the deployment has been updated to 3 using `kubectl get deployments`.

### Step 8: Uninstall the Chart

Uninstall the Helm chart to remove the deployed resources from your Kubernetes cluster.

```bash
helm uninstall my-job-app
```

Verify that the deployment and service are removed using `kubectl get deployments` and `kubectl get services`.


<details>
<summary> Hints (click to expand)</summary>

1. Ensure your Kubernetes cluster is running before installing the chart.
2. Double-check the indentation in your YAML files, as it is crucial for correct parsing.
3. If you encounter issues with the service type `LoadBalancer` in minikube, make sure `minikube tunnel` is running.
4. Use `helm lint .` to check your chart for syntax errors before installing.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

This lab provides a foundational understanding of Helm chart creation and deployment. The `job-app` chart deploys a simple Nginx server, demonstrating how to define deployments, services, and configure them using values. The upgrade and uninstall steps showcase the lifecycle management capabilities of Helm.

</details>


---

## Notes

- **Difficulty:** Medium
- **Estimated time:** 45-75 minutes
- **Technology:** Helm

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
