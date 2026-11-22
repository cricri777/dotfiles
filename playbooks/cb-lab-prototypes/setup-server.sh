#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$here/common.sh"

annotate_tag=v1.6.0
annotate_sha256=868a81f3f5c4e9293edcdeab76fdd271b6956ae7c8f097365e548419f7f45604

ssh "$CB_HOST" sudo bash -s -- "$CB_URL" "$annotate_tag" "$annotate_sha256" <<'REMOTE'
set -euo pipefail
url="$1"
tag="$2"
sha256="$3"
owner="$SUDO_USER"
changed_nginx=0
changed_service=0

install_file() {
  local dest="$1" mode="$2" tmp
  tmp="$(mktemp)"
  cat >"$tmp"
  if [ -f "$dest" ] && cmp -s "$tmp" "$dest"; then
    rm -f "$tmp"
    echo "ok       $dest"
    return 1
  fi
  install -m "$mode" "$tmp" "$dest"
  rm -f "$tmp"
  echo "written  $dest"
  return 0
}

apt-get install -y -q nodejs jq apache2-utils

install -d -o "$owner" -g "$owner" /opt/annotate /etc/annotate /var/lib/annotate /srv/prototypes /srv/prototypes-offline
install -d /etc/nginx/prototypes

server=/opt/annotate/annotate-server.cjs
if ! { [ -f "$server" ] && echo "$sha256  $server" | sha256sum -c --quiet; }; then
  curl -fsSL "https://raw.githubusercontent.com/reviewjs/annotate/$tag/examples/annotate-server.cjs" -o "$server.tmp"
  echo "$sha256  $server.tmp" | sha256sum -c --quiet
  mv "$server.tmp" "$server"
  changed_service=1
  echo "written  $server"
fi

if [ ! -f /etc/annotate/reviews.json ]; then
  echo '{"reviews":[]}' >/etc/annotate/reviews.json
  chown "$owner":"$owner" /etc/annotate/reviews.json
fi

install_file /etc/systemd/system/annotate.service 644 <<UNIT && changed_service=1
[Unit]
Description=annotate comment server for client prototypes
After=network.target

[Service]
User=$owner
Environment=ANNOTATE_CONFIG=/etc/annotate/reviews.json
Environment=DATA_DIR=/var/lib/annotate
Environment=HOST=127.0.0.1
Environment=PORT=8787
ExecStart=/usr/bin/node /opt/annotate/annotate-server.cjs
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT

install_file /etc/nginx/conf.d/prototypes.conf 644 <<NGINX && changed_nginx=1
server {
    listen 127.0.0.1:8090;
    server_name _;
    server_tokens off;
    absolute_redirect off;
    client_max_body_size 1m;
    root /srv/prototypes;
    index index.html;

    location ~ ^/(?<project>[a-z0-9][a-z0-9-]*)/api/v1/annotate/reviews/\\k<project>/(?<apipath>.*)\$ {
        if (!-f /etc/nginx/prototypes/\$project.htpasswd) { return 404; }
        if (-f /srv/prototypes-offline/\$project) { return 503; }
        proxy_pass http://127.0.0.1:8787/v1/annotate/reviews/\$project/\$apipath\$is_args\$args;
        proxy_set_header Origin "$url";
        proxy_set_header Host \$host;
    }

    location ~ ^/(?<project>[a-z0-9][a-z0-9-]*)(/|\$) {
        if (!-f /etc/nginx/prototypes/\$project.htpasswd) { return 404; }
        if (-f /srv/prototypes-offline/\$project) { return 503; }
        auth_basic "Prototype";
        auth_basic_user_file /etc/nginx/prototypes/\$project.htpasswd;
        add_header Cache-Control "no-store";
    }

    location / { return 404; }
}
NGINX

systemctl daemon-reload
systemctl enable annotate >/dev/null 2>&1
if [ "$changed_service" = 1 ]; then
  systemctl restart annotate
else
  systemctl is-active --quiet annotate || systemctl start annotate
fi

nginx -t
if [ "$changed_nginx" = 1 ]; then
  systemctl reload nginx
fi

tailscale serve --bg --https=443 http://127.0.0.1:8090
echo "annotate: $(systemctl is-active annotate)"
REMOTE

echo "setup done: $CB_URL/<project>/"
