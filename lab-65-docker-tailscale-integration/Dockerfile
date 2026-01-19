FROM tailscale/tailscale:latest

RUN apt-get update && apt-get install -y nginx --no-install-recommends

EXPOSE 80

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html

CMD tailscale up --authkey=$TAILSCALE_AUTHKEY --hostname=docker-tailscale --advertise-exit-node=false --advertise-routes=$TAILSCALE_ROUTES && nginx -g 'daemon off;'
