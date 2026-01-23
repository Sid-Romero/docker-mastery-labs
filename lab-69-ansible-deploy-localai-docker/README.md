# Lab 69: Ansible: Deploying LocalAI with Docker

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Ansible](https://img.shields.io/badge/Ansible-EE0000?logo=ansible&logoColor=white)

> **Auto-generated lab** - Created on 2026-01-23

## Description

This lab demonstrates how to use Ansible to automate the deployment of LocalAI, a self-hosted AI platform, using Docker.  You will learn how to write Ansible playbooks to install Docker, configure the LocalAI environment, and start the necessary containers.

## Learning Objectives

- Learn how to write Ansible playbooks for Docker deployment
- Understand how to configure LocalAI using Ansible
- Automate the deployment of a complex application using Ansible

## Prerequisites

- Ansible installed and configured (version 2.9 or later)
- Access to a Linux-based server (e.g., Ubuntu) or VM
- Basic understanding of Docker and Ansible concepts
- Python installed on the target host (for Ansible modules)

## Lab Steps

### Step 1: Step 1: Set up the Ansible Inventory

Create an Ansible inventory file named `inventory.ini` that lists the target server(s) where LocalAI will be deployed. Replace `<your_server_ip>` with the actual IP address or hostname of your server. 

```ini
[localai_servers]
localai_server ansible_host=<your_server_ip> ansible_user=your_user ansible_ssh_private_key_file=~/.ssh/id_rsa

[localai_servers:vars]
ansible_python_interpreter=/usr/bin/python3
```

Ensure that your Ansible control node can connect to the target server via SSH using the specified user and private key. Adjust `ansible_user` and `ansible_ssh_private_key_file` accordingly.

Test connectivity:
```bash
ansible -i inventory.ini all -m ping
```
You should see a successful `pong` response from your target server.

### Step 2: Step 2: Create the Ansible Playbook

Create a file named `localai_deploy.yml` with the following content. This playbook will install Docker, download the LocalAI Docker Compose file, and start the LocalAI containers.

```yaml
---
- hosts: localai_servers
  become: true
  tasks:
    - name: Update apt cache
      apt: update_cache=yes cache_valid_time=3600

    - name: Install required packages for Docker
      apt: name={{ item }} state=present
      loop:
        - apt-transport-https
        - ca-certificates
        - curl
        - software-properties-common

    - name: Add Docker GPG key
      apt_key: url=https://download.docker.com/linux/ubuntu/gpg

    - name: Add Docker repository
      apt_repository: repo='deb https://download.docker.com/linux/ubuntu focal stable'

    - name: Install Docker
      apt: name={{ item }} state=present
      loop:
        - docker-ce
        - docker-ce-cli
        - containerd.io

    - name: Install Docker Compose
      apt: name=docker-compose state=present

    - name: Create LocalAI directory
      file:
        path: /opt/localai
        state: directory
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"

    - name: Download Docker Compose file for LocalAI
      get_url:
        url: https://raw.githubusercontent.com/mudler/LocalAI/main/docker-compose.yml
        dest: /opt/localai/docker-compose.yml
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"

    - name: Start LocalAI containers
      community.docker.docker_compose:
        project_src: /opt/localai
        state: present
```

**Explanation:**
*   `hosts: localai_servers`:  Specifies the target servers from the inventory.
*   `become: true`:  Enables privilege escalation (sudo).
*   `tasks`:  A list of tasks to be executed.
*   `apt`:  Installs packages using the apt package manager.
*   `get_url`: Downloads the Docker Compose file from the LocalAI repository.
*   `community.docker.docker_compose`:  Deploys the Docker Compose file.  You may need to install the `community.docker` collection: `ansible-galaxy collection install community.docker`
*   Notice the use of `ansible_user` variable. This is automatically available within Ansible and represents the user you are connecting to the host as.


### Step 3: Step 3: Run the Ansible Playbook

Execute the Ansible playbook using the following command:

```bash
ansible-playbook -i inventory.ini localai_deploy.yml
```

Ansible will connect to the target server, install Docker and Docker Compose, download the LocalAI Docker Compose file, and start the containers. Monitor the output for any errors.


### Step 4: Step 4: Verify the Deployment

After the playbook completes successfully, verify that the LocalAI containers are running on the target server. SSH into the server and run:

```bash
docker ps
```

You should see containers related to LocalAI running.  You can also check the logs of the containers to ensure they are starting correctly:

```bash
docker logs localai-api
```

(Replace `localai-api` with the actual container name.)  Once the API is running, you can access it through its exposed port (check `docker-compose.yml` for the exact port number).


<details>
<summary> Hints (click to expand)</summary>

1. Ensure that the Ansible user has sudo privileges on the target server.
2. Verify that the Docker Compose file is downloaded correctly.
3. Check the Docker logs for any errors during container startup.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The solution involves creating an Ansible playbook that automates the installation of Docker, downloads the LocalAI Docker Compose file, and starts the LocalAI containers. The inventory file specifies the target server, and the playbook uses Ansible modules to perform the necessary tasks. Successful execution of the playbook results in a running LocalAI instance on the target server.

</details>


---

## Notes

- **Difficulty:** Medium
- **Estimated time:** 45-75 minutes
- **Technology:** Ansible

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
