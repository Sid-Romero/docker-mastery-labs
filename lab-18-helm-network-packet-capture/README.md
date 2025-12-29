# Lab 18: Helm Chart for Network Packet Capture with tcpdump

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Helm](https://img.shields.io/badge/Helm-0F1689?logo=helm&logoColor=white)

> **Auto-generated lab** - Created on 2025-12-29

## Description

This lab guides you through creating a Helm chart to deploy a pod that captures network packets using tcpdump. You will learn how to parameterize the deployment using values.yaml and how to use ConfigMaps to inject tcpdump commands.

## Learning Objectives

- Create a basic Helm chart.
- Parameterize a deployment using values.yaml.
- Use ConfigMaps to configure tcpdump.
- Deploy and manage applications with Helm.

## Prerequisites

- kubectl installed and configured to connect to a Kubernetes cluster (minikube, Docker Desktop, or similar)
- Helm installed
- Basic understanding of Kubernetes concepts (Pods, Deployments, ConfigMaps)

## Lab Steps

### Step 1: Step 1: Create a Helm Chart

First, create a new Helm chart named `tcpdump-capture` using the following command:

```bash
helm create tcpdump-capture
cd tcpdump-capture
```

This will generate a basic chart structure with default files.

### Step 2: Step 2: Define the Pod Specification

Modify the `templates/deployment.yaml` file to define a Pod that runs `tcpdump`. Replace the existing content with the following:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "tcpdump-capture.fullname" . }}
  labels:
    {{- include "tcpdump-capture.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "tcpdump-capture.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "tcpdump-capture.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          command: ["/bin/sh", "-c"]
          args: ["tcpdump {{ .Values.tcpdump.flags }} -w /tmp/capture.pcap; while true; do sleep 3600; done"]
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
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


### Step 3: Step 3: Configure values.yaml

Modify the `values.yaml` file to configure the `tcpdump` command and image. Add a `tcpdump` section to define the flags and update the image settings.  Replace the content with the following. Ensure your image is accessible from your cluster.  A public image is recommended for this lab:

```yaml
replicaCount: 1

image:
  repository: docker.io/library/alpine
  pullPolicy: IfNotPresent
  tag: "latest"

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations: {}
  name: ""

podAnnotations: {}

podSecurityContext: {}

securityContext: {}

service:
  type: ClusterIP
  port: 80

resources: {}

nodeSelector: {}

tolerations: []

affinity: {}

tcpdump:
  flags: "-i any -n"

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
  # targetMemoryUtilizationPercentage: 80


```

### Step 4: Step 4: Deploy the Chart

Deploy the chart to your Kubernetes cluster using the following command:

```bash
helm install my-tcpdump ./tcpdump-capture
```

Replace `my-tcpdump` with a name of your choice for the release.

### Step 5: Step 5: Verify the Deployment

Verify that the Pod is running and capturing traffic. Get the Pod name:

```bash
kubectl get pods
```

Then, exec into the Pod and check the `capture.pcap` file:

```bash
kubectl exec -it <pod-name> -- /bin/sh
ls -l /tmp/capture.pcap
```

If the file exists and has a size greater than zero, it means that `tcpdump` is capturing traffic.

### Step 6: Step 6: Customize tcpdump Flags

Modify the `values.yaml` file to change the `tcpdump` flags. For example, to capture only HTTP traffic, change the `tcpdump.flags` value to `-i any -n port 80`.  

Then upgrade the chart:
```bash
helm upgrade my-tcpdump ./tcpdump-capture
```

Verify the changes by exec-ing into the pod again and checking the captured traffic.


<details>
<summary> Hints (click to expand)</summary>

1. Ensure the image specified in `values.yaml` is accessible from your Kubernetes cluster.
2. Check the Pod logs if `tcpdump` is not capturing traffic as expected.  `kubectl logs <pod-name>`
3. Remember to upgrade the Helm release after modifying `values.yaml`.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

This lab demonstrates how to use Helm to deploy a simple application with configurable parameters. By modifying the `values.yaml` file, you can easily customize the `tcpdump` command and image used by the Pod. This is a basic example of how Helm can be used to manage complex deployments in Kubernetes.

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
