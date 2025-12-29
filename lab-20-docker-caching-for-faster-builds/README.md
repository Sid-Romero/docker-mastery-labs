# Lab 20: Docker Caching for Faster Builds

![Difficulty: Easy](https://img.shields.io/badge/Difficulty-Easy-brightgreen) ![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)

> **Auto-generated lab** - Created on 2025-12-29

## Description

This lab demonstrates how Docker's caching mechanism works and how to optimize your Dockerfiles to leverage caching effectively for faster build times. We'll build a simple Node.js application and see how changing different parts of the Dockerfile affects cache invalidation.

## Learning Objectives

- Understand how Docker's layer caching works.
- Identify Dockerfile instructions that invalidate the cache.
- Optimize Dockerfiles for faster build times by leveraging caching.

## Prerequisites

- Docker installed and running
- Basic understanding of Dockerfiles

## Lab Steps

### Step 1: Create a Simple Node.js Application

First, let's create a simple Node.js application. Create a directory for your project:

```bash
mkdir docker-cache-lab
cd docker-cache-lab
```

Create a `package.json` file:

```bash
npm init -y
```

Create an `index.js` file:

```javascript
// index.js
const http = require('http');

const hostname = '0.0.0.0';
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello, World!\n');
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});
```

Add a dependency. Let's use `express`:

```bash
npm install express
```

Modify `index.js` to use `express`:

```javascript
// index.js
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
```

### Step 2: Create a Basic Dockerfile

Now, let's create a basic Dockerfile. Create a file named `Dockerfile` in the same directory as your application:

```dockerfile
# Dockerfile
FROM node:16

WORKDIR /app

COPY package*.json . # Copy package.json and package-lock.json

RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "index.js"]
```

### Step 3: Build the Docker Image and Observe Caching

Build the Docker image:

```bash
docker build -t node-app .
```

Observe the output. Docker will cache each layer. Now, build the image again:

```bash
docker build -t node-app .
```

Notice that Docker uses the cached layers.  The `Using cache` message indicates a layer was restored from the cache.


### Step 4: Modify the Application and Observe Cache Invalidation

Now, let's modify the `index.js` file.  Change the greeting:

```javascript
// index.js
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello World from Docker!')
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
```

Build the image again:

```bash
docker build -t node-app .
```

Notice that the layers after the `COPY . .` instruction are rebuilt. This is because changing `index.js` invalidates the cache for that layer and all subsequent layers.


### Step 5: Optimize the Dockerfile for Caching

To optimize the Dockerfile, we can move the `COPY package*.json .` and `RUN npm install` instructions *before* the `COPY . .` instruction.  This way, if only application code changes, the dependencies don't need to be reinstalled every time.  Modify your Dockerfile to look like this:

```dockerfile
# Dockerfile
FROM node:16

WORKDIR /app

COPY package*.json .
RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "index.js"]
```

Build the image again:

```bash
docker build -t node-app .
```

Now, modify `index.js` again (change the greeting back or to something else) and build the image again.  Notice that the `npm install` layer is now cached, resulting in a faster build.


### Step 6: Further Optimization: Multi-Stage Builds

For a truly optimized build, especially for production, consider multi-stage builds. This allows you to separate the build environment from the runtime environment. Here's an example:

```dockerfile
# Dockerfile
# Stage 1: Build
FROM node:16 AS builder
WORKDIR /app
COPY package*.json .
RUN npm install
COPY . .

# Stage 2: Production
FROM node:16-slim
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json .
COPY --from=builder /app/index.js .

EXPOSE 3000
CMD ["node", "index.js"]
```

Build the image:

```bash
docker build -t node-app .
```

This approach keeps the final image smaller by only including the necessary runtime dependencies and application code.


<details>
<summary> Hints (click to expand)</summary>

1. Remember that Docker caches layers based on the instructions in the Dockerfile.  If an instruction changes, the cache for that layer and all subsequent layers is invalidated.
2. Consider the order of instructions in your Dockerfile. Place instructions that change less frequently earlier in the file to maximize cache utilization.
3. Use `.dockerignore` to exclude unnecessary files and directories from the build context, reducing the size of the copied data and improving build times.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The solution involves creating a simple Node.js application and then iteratively modifying the Dockerfile to optimize caching. The key is to understand that Docker caches layers based on the Dockerfile instructions and that the order of these instructions matters significantly for build performance. Moving dependency installation before copying the application code allows the dependency layer to be cached when only the application code changes.

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
