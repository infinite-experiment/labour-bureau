docker rm -f caddy

docker run -d \
  --name caddy \
  --network labour-bureau_internal \
  -p 80:80 -p 443:443 \
  -v "$PWD/Caddyfile":/etc/caddy/Caddyfile:ro \
  -v caddy_data:/data \
  -v caddy_config:/config \
  caddy:2-alpine