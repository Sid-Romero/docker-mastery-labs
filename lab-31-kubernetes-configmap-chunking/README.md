# Lab 31: Kubernetes: ConfigMap Chunking for Large Configurations

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)

> **Auto-generated lab** - Created on 2025-12-31

## Description

This lab explores strategies for handling large configuration files in Kubernetes that exceed the 1MiB ConfigMap limit. We will implement a chunking mechanism to split a large configuration into multiple ConfigMaps and then reassemble them within a Pod.

## Learning Objectives

- Understand the limitations of Kubernetes ConfigMaps.
- Learn how to split a large configuration file into smaller chunks.
- Implement a Pod that can reassemble a configuration from multiple ConfigMaps.
- Explore different approaches to ConfigMap management for large configurations.

## Prerequisites

- kubectl installed and configured to connect to a Kubernetes cluster (minikube, Docker Desktop, or similar)
- Basic understanding of Kubernetes concepts (Pods, ConfigMaps)

## Lab Steps

### Step 1: 1. Create a Large Configuration File

First, let's generate a large configuration file that exceeds the 1MiB limit.  We'll use `openssl` to create a file filled with random data.

```bash
openssl rand -base64 $((1024 * 1024 * 1.2)) -out large-config.txt
```

This command creates a file named `large-config.txt` with approximately 1.2MB of random data.  Verify the file size:

```bash
ls -l large-config.txt
```

**Note:** The exact size might vary slightly.

### Step 2: 2. Attempt to Create a ConfigMap (and Fail)

Now, try to create a ConfigMap directly from this large file.  This will demonstrate the ConfigMap size limitation.

```bash
kubectl create configmap large-config --from-file=large-config.txt
```

You should see an error message indicating that the ConfigMap size exceeds the allowed limit.  This confirms the problem we're trying to solve.

### Step 3: 3. Chunk the Configuration File

We'll split the large configuration file into smaller chunks.  A simple approach is to use the `split` command.

```bash
split -C 200k large-config.txt config-chunk-
```

This command splits `large-config.txt` into files named `config-chunk-aa`, `config-chunk-ab`, `config-chunk-ac`, and so on.  The `-C 200k` option ensures each chunk is approximately 200KB in size (adjust as needed to stay well below the 1MiB limit).

Verify the creation of the chunk files.

```bash
ls -l config-chunk-*
```

**Note:** The number of chunk files will depend on the original file size and the chunk size specified. You may need to install the `split` command if it is not already present on your system.

### Step 4: 4. Create ConfigMaps for Each Chunk

Now, create a ConfigMap for each chunk file.  We'll use a simple loop to automate this.

```bash
for file in config-chunk-*; do
  name=$(echo $file | sed 's/[^a-zA-Z0-9-]/-/g')  # Sanitize filename for ConfigMap name
  kubectl create configmap "${name}" --from-file="${file}"
done
```

This loop iterates through each chunk file, creates a ConfigMap with a name derived from the filename, and populates the ConfigMap with the contents of the chunk file. The `sed` command ensures the ConfigMap name is valid by replacing any invalid characters with hyphens.

Verify the creation of ConfigMaps.

```bash
kubectl get configmaps
```

### Step 5: 5. Create a Pod to Reassemble the Configuration

Next, we'll create a Pod that mounts all the ConfigMaps and reassembles the original configuration file. Create a file named `pod.yaml` with the following content:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-reassembler
spec:
  containers:
  - name: main
    image: busybox:latest
    command: ['/bin/sh', '-c']
    args: [
      'cat /config-chunks/* > /output/reassembled-config.txt && cat /output/reassembled-config.txt | head -c 100 ; sleep infinity'
    ]
    volumeMounts:
    - name: config-volume
      mountPath: /config-chunks
    - name: output-volume
      mountPath: /output
  volumes:
  - name: config-volume
    projected:
      sources:
      # Dynamically populate this section based on your configmap names.
      # Example:
      - configMap:
          name: config-chunk-aa
          items:
          - key: config-chunk-aa
            path: config-chunk-aa
      - configMap:
          name: config-chunk-ab
          items:
          - key: config-chunk-ab
            path: config-chunk-ab
  - name: output-volume
    emptyDir: {}

```

**Important:** You need to dynamically populate the `projected.sources` section with the names of *all* the ConfigMaps you created in the previous step.  Each ConfigMap needs its own entry.  The `path` should match the ConfigMap's data key (which will be the same as the filename we used).

Create the Pod:

```bash
kubectl apply -f pod.yaml
```

### Step 6: 6. Verify the Reassembled Configuration

Once the Pod is running, verify that the configuration file has been reassembled correctly.  We'll execute a command inside the Pod to check the beginning of the reassembled file.  This is just a basic check; a more robust verification might involve checksums or comparing the reassembled file to the original.

```bash
kubectl exec config-reassembler -- cat /output/reassembled-config.txt | head -c 100
```

Compare the output with the first 100 characters of the original `large-config.txt` file. They should match.

```bash
head -c 100 large-config.txt
```

### Step 7: 7. Cleanup

Clean up the resources created during this lab.

```bash
kubectl delete pod config-reassembler
for file in config-chunk-*; do
  name=$(echo $file | sed 's/[^a-zA-Z0-9-]/-/g')
  kubectl delete configmap "${name}"
done
rm -f large-config.txt config-chunk-*
```


<details>
<summary> Hints (click to expand)</summary>

1. Ensure you correctly populate the `projected.sources` section in `pod.yaml` with all the ConfigMap names.
2. If the Pod fails to start, check the logs for errors related to volume mounting or file access permissions.
3. Adjust the `-C` argument in the `split` command to create smaller chunks if necessary.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The solution involves splitting a large configuration file into smaller chunks, creating a ConfigMap for each chunk, and then using a Pod with a `projected` volume source to reassemble the configuration from the individual ConfigMaps. This allows you to overcome the 1MiB ConfigMap limit. Consider using a more robust approach for production environments, such as external configuration management tools.

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
