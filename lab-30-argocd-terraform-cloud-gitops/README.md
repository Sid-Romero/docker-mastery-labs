# Lab 30: ArgoCD: Managing Terraform Cloud with GitOps

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?logo=argo&logoColor=white)

> **Auto-generated lab** - Created on 2025-12-31

## Description

This lab demonstrates how to integrate ArgoCD with Terraform Cloud to manage infrastructure as code using GitOps principles. It focuses on automating Terraform Cloud workspace updates based on Git repository changes.

## Learning Objectives

- Set up ArgoCD to monitor a Git repository containing Terraform configurations.
- Configure ArgoCD to trigger Terraform Cloud workspace updates upon code changes.
- Understand the GitOps workflow for managing infrastructure changes with Terraform Cloud.

## Prerequisites

- Docker installed
- kubectl installed and configured
- ArgoCD installed in a Kubernetes cluster (follow the official ArgoCD installation guide)
- Terraform Cloud account with a workspace created
- Terraform CLI installed

## Lab Steps

### Step 1: Set up a Terraform Cloud Workspace

If you don't already have one, create a Terraform Cloud workspace. You will need to create a Terraform Cloud API token with sufficient permissions to manage workspaces and variables.

1.  Navigate to your Terraform Cloud organization.
2.  Create a new workspace. Choose a name for your workspace (e.g., `argocd-demo`).
3.  Set the execution mode to 'Remote'.
4.  Create an API token in Terraform Cloud under your user settings. Ensure it has write permissions.
5.  Store the API token securely; you will need it later.

**Note:** You will need the Terraform Cloud organization name and workspace name later.

### Step 2: Create a Terraform Configuration Repository

Create a Git repository to store your Terraform configuration. This repository will be monitored by ArgoCD.

1.  Create a new directory for your Terraform configuration (e.g., `terraform-repo`).
2.  Inside the directory, create a file named `main.tf` with the following content:

```terraform
terraform {
  cloud {
    organization = "<YOUR_TERRAFORM_CLOUD_ORGANIZATION>"

    workspaces {
      name = "<YOUR_TERRAFORM_CLOUD_WORKSPACE_NAME>"
    }
  }
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "random" {}

resource "random_string" "random" {
  length = 16
  special = true
}

output "random_string" {
  value = random_string.random.result
}
```

   Replace `<YOUR_TERRAFORM_CLOUD_ORGANIZATION>` and `<YOUR_TERRAFORM_CLOUD_WORKSPACE_NAME>` with your actual Terraform Cloud organization and workspace names.

3.  Initialize the Terraform configuration:

```bash
terraform init
```

4.  Create a `.gitignore` file to exclude the `.terraform` directory and other local files.

5.  Commit and push the changes to your Git repository (e.g., GitHub, GitLab, Bitbucket).

**Note:** This example uses a simple `random_string` resource. You can adapt it to manage more complex infrastructure.

### Step 3: Create an ArgoCD Application

Create an ArgoCD application that points to your Terraform configuration repository.

1.  Create an ArgoCD application using the ArgoCD UI or the `argocd` CLI.

    **Using the CLI:**

    Create a YAML file named `argocd-app.yaml` with the following content:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: terraform-cloud-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: <YOUR_GIT_REPOSITORY_URL>
    targetRevision: HEAD
    path: .
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=false
```

    Replace `<YOUR_GIT_REPOSITORY_URL>` with the URL of your Git repository.

2.  Apply the YAML file to create the ArgoCD application:

```bash
kubectl apply -f argocd-app.yaml -n argocd
```

**Note:** Ensure the `path` in the `source` section points to the directory containing your `main.tf` file.  The `destination` should point to your Kubernetes cluster.

### Step 4: Configure Terraform Cloud Variables

Configure the necessary Terraform Cloud variables for your workspace.

1.  In your Terraform Cloud workspace, add the following environment variables:
    *   `TF_TOKEN_app_terraform_io`: Set the value to your Terraform Cloud API token.
    *   `TF_CLI_ARGS`: Set the value to `-no-color` (optional, but recommended for cleaner output).
2.  Also, add a Terraform variable named `TF_VAR_random_length` with a default value of `10` (or any other integer). This variable will be used to configure the `random_string` resource. Set it to be **terraform** type and not environment variable.

**Note:** `TF_TOKEN_app_terraform_io` is the standard environment variable name for authenticating with Terraform Cloud when using the Terraform CLI. The suffix `_app_terraform_io` is important.

### Step 5: Observe ArgoCD and Terraform Cloud Synchronization

Observe ArgoCD synchronizing your Terraform configuration with Terraform Cloud.

1.  In the ArgoCD UI, monitor the `terraform-cloud-app` application.  You should see that it is initially out of sync.
2.  Manually trigger a sync in ArgoCD. This should trigger a Terraform run in your Terraform Cloud workspace.
3.  Check the Terraform Cloud workspace. You should see a new run being executed based on the configuration in your Git repository.
4.  Verify that the `random_string` resource is created and that the output value is displayed in Terraform Cloud.

**Note:** The first sync might take a few minutes to complete as Terraform initializes the provider and creates the resources.

### Step 6: Test GitOps Workflow

Test the GitOps workflow by making changes to your Terraform configuration and observing ArgoCD automatically synchronize the changes.

1.  Modify the `length` attribute of the `random_string` resource in your `main.tf` file to a different value (e.g., `length = 20`).
2.  Commit and push the changes to your Git repository.
3.  ArgoCD should automatically detect the changes and trigger a new synchronization.
4.  Check the Terraform Cloud workspace. You should see a new run being executed with the updated configuration.
5.  Verify that the `random_string` resource is updated with the new length.

**Note:** ArgoCD's `automated` sync policy ensures that any changes in the Git repository are automatically applied to your Terraform Cloud workspace.


<details>
<summary> Hints (click to expand)</summary>

1. Ensure that the ArgoCD application is configured with the correct repository URL and path.
2. Double-check the Terraform Cloud API token and environment variables for accuracy.
3. Verify that the ArgoCD sync policy is set to `automated` for automatic synchronization.
4. If ArgoCD shows an error related to Terraform Cloud authentication, ensure that the TF_TOKEN_app_terraform_io environment variable is correctly configured.
5. Make sure the `path` in the ArgoCD application points to the root directory containing your Terraform configuration files.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The solution involves configuring ArgoCD to monitor a Git repository containing Terraform configurations and automatically triggering Terraform Cloud workspace updates upon code changes.  Key aspects include setting up the ArgoCD application with the correct repository URL, configuring Terraform Cloud environment variables for authentication, and enabling the `automated` sync policy for continuous synchronization. The lab demonstrates how to manage infrastructure as code using GitOps principles with ArgoCD and Terraform Cloud.

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
