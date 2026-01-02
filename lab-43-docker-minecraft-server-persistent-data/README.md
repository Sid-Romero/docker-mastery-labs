# Lab 43: Docker Minecraft Server with Persistent Data

![Difficulty: Easy](https://img.shields.io/badge/Difficulty-Easy-brightgreen) ![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)

> **Auto-generated lab** - Created on 2026-01-02

## Description

This lab guides you through creating a Docker container for a Minecraft server using the itzg/docker-minecraft-server image, focusing on persistent data storage and basic configuration. You'll learn how to configure environment variables, map volumes for persistent data, and manage the server lifecycle.

## Learning Objectives

- Learn how to use pre-built Docker images for applications.
- Understand how to configure Docker containers using environment variables.
- Learn how to persist data using Docker volumes.
- Understand basic Docker container lifecycle management.

## Prerequisites

- Docker installed and running (Docker Desktop, Docker Engine, etc.)
- Basic familiarity with command-line interface

## Lab Steps

### Step 1: Pull the Minecraft Server Image

First, pull the `itzg/minecraft-server` image from Docker Hub. This image provides a pre-configured Minecraft server environment.

```bash
docker pull itzg/minecraft-server
```

Verify the image has been downloaded successfully using:

```bash
docker images
```
You should see `itzg/minecraft-server` in the list of images.

### Step 2: Create a Data Volume

Next, create a Docker volume to store the Minecraft server data. This ensures that your world, player data, and server configurations are preserved even if the container is stopped or removed.

```bash
docker volume create mc-data
```

Verify the volume creation:

```bash
docker volume ls
```
You should see `mc-data` in the list of volumes.

### Step 3: Run the Minecraft Server Container

Now, run the Minecraft server container, mapping the `mc-data` volume to the `/data` directory inside the container. Also, set the `EULA` environment variable to `TRUE` to accept the Minecraft End User License Agreement.  We will also set the version of minecraft we wish to run using the `VERSION` variable.

```bash
docker run -d -e EULA=TRUE -e VERSION=1.20.4 -v mc-data:/data -p 25565:25565 --name mc itzg/minecraft-server
```

*   `-d`: Runs the container in detached mode (in the background).
*   `-e EULA=TRUE`: Sets the environment variable `EULA` to `TRUE`, accepting the Minecraft EULA.
*   `-v mc-data:/data`: Mounts the `mc-data` volume to the `/data` directory inside the container.  This is where the minecraft world, player data, and server configuration are stored.
*   `-p 25565:25565`: Maps port 25565 on the host machine to port 25565 in the container (the default Minecraft server port).
*   `--name mc`: Assigns the name `mc` to the container.
*   `itzg/minecraft-server`: Specifies the image to use for the container.

Check the container's status:

```bash
docker ps
```
You should see the `mc` container running.

### Step 4: View Server Logs

To monitor the server's startup process and check for any errors, view the container logs:

```bash
docker logs mc -f
```

`-f` flag follows the log output in real-time.  The server may take several minutes to start as it generates the world.  Look for the message "Done (xx.xxx)s! For help, type "help"" in the logs, which indicates the server has started successfully.

### Step 5: Connect to the Minecraft Server

Once the server is running, you can connect to it using the Minecraft client. Launch Minecraft, click "Add Server", and enter `localhost` as the server address. If you are running docker on a remote machine, you will need to use the public IP address of that machine.

Join the server and start playing!

### Step 6: Stop and Restart the Server

Stop the Minecraft server container:

```bash
docker stop mc
```

Start the Minecraft server container again:

```bash
docker start mc
```

Connect to the server again to verify that your world and player data have been preserved. This demonstrates the persistence provided by the Docker volume.

### Step 7: Configure the Server (Optional)

You can customize the Minecraft server by modifying the `server.properties` file located in the `mc-data` volume on your host machine.  First, locate the volume on your system.

```bash
docker volume inspect mc-data
```

This command will output JSON containing the mountpoint of the volume on your host.  The output will look something like this:

```json
[
    {
        "CreatedAt": "2024-10-27T14:00:00Z",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/mc-data/_data",
        "Name": "mc-data",
        "Options": {},
        "Scope": "local"
    }
]
```

In this example, the mountpoint is `/var/lib/docker/volumes/mc-data/_data`. Navigate to this directory in your terminal or file explorer.

Edit the `server.properties` file to change settings like the server name, difficulty, game mode, etc.  For example:

```bash
cd /var/lib/docker/volumes/mc-data/_data
vi server.properties
```

After making changes, restart the container for the changes to take effect:

```bash
docker restart mc
```

**Note:** The exact location of the Docker volume may vary depending on your operating system and Docker configuration.


<details>
<summary> Hints (click to expand)</summary>

1. Make sure Docker is running before executing any commands.
2. Check the container logs if you encounter issues connecting to the server.
3. The Minecraft server may take a few minutes to start up completely.
4. Ensure port 25565 is not blocked by your firewall.
5. Double-check the volume mountpoint if you cannot find the server data on your host machine.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The solution involves pulling the `itzg/minecraft-server` image, creating a Docker volume for persistent data, running the container with the necessary environment variables and volume mappings, and optionally configuring the server by modifying the `server.properties` file. The data volume ensures that the world and player data are preserved across container restarts.

</details>


---

## Notes

- **Difficulty:** Easy
- **Estimated time:** 30-45 minutes
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
