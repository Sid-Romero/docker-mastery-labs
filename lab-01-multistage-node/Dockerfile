# Layer 0 : Base image
FROM node:18

# Layer 1 : Set working directory
WORKDIR /usr/src/app

 # Layer 2 : specify dependencies
COPY package.json package-lock.json ./

# Layer 3 : Install app dependencies
RUN npm install x

# Layer 4 : Copy app source code
COPY . .

# Expose port used in the app
EXPOSE 8080

 # Entrypoint
CMD ["node", "server.js"]

