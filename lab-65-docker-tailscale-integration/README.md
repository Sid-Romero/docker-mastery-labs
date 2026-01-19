# Lab 65: Secure Docker Server with Tailscale

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)

> **Auto-generated lab** - Created on 2026-01-19

## Description

This lab demonstrates how to integrate a Docker container into a Tailscale network, enabling secure and private access to the containerized application. It uses host networking and an authentication key for seamless integration.

## Learning Objectives

- Learn how to run Tailscale within a Docker container.
- Understand the importance of host networking for Tailscale integration.
- Securely authenticate a Tailscale client using an auth key.
- Access a service running inside a Docker container through the Tailscale network.

## Prerequisites

- Docker installed and running on your local machine.
- A Tailscale account.
- Tailscale CLI installed (optional, for easier key generation and status checking).

## Lab Steps

### Step 1: Create a Tailscale Auth Key

First, generate a reusable auth key in your Tailscale admin panel (https://login.tailscale.com/admin/settings/authkeys). Make sure to mark the key as 'reusable'.

Alternatively, use the Tailscale CLI:

```bash
tailscale authkey create --reusable
```

Save the generated key; you will need it later.  This key allows the container to join your tailnet without interactive authentication.

**Note:** Treat this key like a password. Do not commit it to public repositories.

### Step 2: Prepare the Dockerfile

Create a `Dockerfile` with the following content. This Dockerfile uses the official Tailscale image and installs a simple HTTP server (`nginx`) for demonstration purposes.

```dockerfile
FROM tailscale/tailscale:latest

RUN apt-get update && apt-get install -y nginx --no-install-recommends

EXPOSE 80

COPY nginx.conf /etc/nginx/nginx.conf

CMD tailscale up --authkey=$TAILSCALE_AUTHKEY --hostname=docker-tailscale --advertise-exit-node=false --advertise-routes=$TAILSCALE_ROUTES && nginx -g 'daemon off;'
```

**Explanation:**
*   `FROM tailscale/tailscale:latest`: Uses the official Tailscale Docker image.
*   `RUN apt-get update && apt-get install -y nginx --no-install-recommends`: Installs `nginx`.
*   `EXPOSE 80`: Exposes port 80 for `nginx`.
*   `CMD tailscale up ... && nginx -g 'daemon off;'`: Starts Tailscale and then starts `nginx`.  `--advertise-exit-node=false` prevents this container from acting as a exit node.  The `--advertise-routes` parameter allows specifying routes to advertise to the tailnet.  We'll configure this later.

Create a simple `nginx.conf` file:

```nginx
worker_processes auto;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;

    server {
        listen 80;
        server_name localhost;

        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
        }
    }
}
```

Create a simple `index.html` file to serve with nginx:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Tailscale Docker Demo</title>
</head>
<body>
    <h1>Hello from Tailscale Docker!</h1>
</body>
</html>
```

### Step 3: Build and Run the Docker Container

Build the Docker image.  Replace `YOUR_TAILSCALE_AUTHKEY` with the actual auth key you generated earlier.  The `--build-arg` is used to pass the auth key to the Dockerfile.  Also, replace `YOUR_TAILSCALE_ROUTES` with the routes you want to advertise to your tailnet.  If you don't need any routes, you can set it to an empty string.

```bash
export TAILSCALE_AUTHKEY=YOUR_TAILSCALE_AUTHKEY
export TAILSCALE_ROUTES=YOUR_TAILSCALE_ROUTES

docker build -t tailscale-nginx .
```

Run the Docker container using host networking.  This is important for Tailscale to function correctly.

```bash
docker run --name tailscale-nginx --net=host --cap-add=NET_ADMIN -e TAILSCALE_AUTHKEY=$TAILSCALE_AUTHKEY -e TAILSCALE_ROUTES=$TAILSCALE_ROUTES tailscale-nginx
```

**Explanation:**
*   `--net=host`: Uses the host's network stack.
*   `--cap-add=NET_ADMIN`: Grants the container the `NET_ADMIN` capability, which is required for Tailscale to manage network interfaces.
*   `-e TAILSCALE_AUTHKEY=$TAILSCALE_AUTHKEY`:  Passes the Tailscale auth key as an environment variable.
*   `-e TAILSCALE_ROUTES=$TAILSCALE_ROUTES`: Passes the Tailscale routes as an environment variable.

**Troubleshooting:** If you encounter errors related to network capabilities, ensure that your Docker daemon is configured to allow containers to modify the host's network configuration.

### Step 4: Access the Container via Tailscale

After the container starts, check your Tailscale admin panel (https://login.tailscale.com/admin/machines) to see if the 'docker-tailscale' machine has joined your tailnet.  It might take a minute or two to appear.

Once the machine is online, you can access the `nginx` server running inside the container using its Tailscale IP address.  Find the Tailscale IP in the admin panel and open it in your browser (e.g., `http://100.x.y.z`).  You should see the "Hello from Tailscale Docker!" message.

Alternatively, you can ping the container's Tailscale IP address from another machine on your tailnet to verify connectivity.

```bash
tailscale ping 100.x.y.z
```

### Step 5: Clean Up

To stop and remove the container, run:

```bash
docker stop tailscale-nginx
docker rm tailscale-nginx
```


<details>
<summary> Hints (click to expand)</summary>

1. Ensure the Tailscale auth key is valid and has not expired.
2. Double-check that host networking is enabled for the container (`--net=host`).
3. Verify that the `NET_ADMIN` capability is granted to the container (`--cap-add=NET_ADMIN`).
4. If you cannot access the container via its Tailscale IP, check the Tailscale admin panel to see if the machine is online and authorized.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The core of the solution is running the `tailscale up` command within the Docker container with the correct parameters (auth key, hostname, and networking configuration). Host networking is crucial for Tailscale to function correctly because it needs direct access to the host's network interfaces. The `NET_ADMIN` capability is also essential for Tailscale to manage these interfaces. By authenticating with an auth key, the container automatically joins the Tailscale network without requiring interactive login.

</details>


---

## Notes

- **Difficulty:** Medium
- **Estimated time:** 45-75 minutes
- **Technology:** Docker

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
