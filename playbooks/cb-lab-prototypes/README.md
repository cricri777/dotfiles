# Playbook: client prototypes on cb-lab

Hosts static HTML prototypes for clients on cb-lab, behind Tailscale and a password, with inline comments the agent can read. The `/cricri-ui-prototype` skill calls these scripts. The day-to-day steps are in [docs/ui-prototype.md](../../docs/ui-prototype.md).

## How it works

```
client browser, cb-lab shared to the client in Tailscale
  -> https://cb-lab.tail66d40f.ts.net/<project>/     tailscale serve, tailnet only, port 443
  -> nginx 127.0.0.1:8090
       /<project>/                  password per project, files from /srv/prototypes/<project>
       /<project>/api/v1/annotate/reviews/<project>/...  annotate server 127.0.0.1:8787
```

- Pages are static files served from a checkout of the private bare repo `~/git/prototypes/<project>.git`. `deploy.sh` updates the checkout after every push.
- Comments use annotate.js and its reference server, pinned by tag and sha256 in `setup-server.sh`. The server stores one JSON file per project in `/var/lib/annotate/`.
- The comment API has no nginx password, because the browser sends its own `Authorization: Bearer` header there. The API refuses every call without a session from a valid invite token, and nginx only forwards the project's own review path.
- nginx sets the `Origin` header itself, because browsers omit it on same-origin GET requests and the annotate server requires it.
- Each project has 2 invites. `client` goes in the client link, and `claude` is the review author that `feedback.sh` uses. Only `claude` sees every comment and can reply and set a status.
- Nothing listens outside `127.0.0.1` except the existing Tailscale and ssh ports. The git site on port 8080 is not touched.

## One-time setup

1. Run `./setup-server.sh`. It installs `nodejs`, `jq`, `apache2-utils`, the annotate server and its systemd unit, the nginx config and the `tailscale serve` mapping. It is safe to rerun and prints `ok` for anything that did not change.
2. In the Tailscale admin console, check that HTTPS certificates are on.
3. Add a grant so shared users reach only port 443. Put it after your own grants:

   ```json
   {"src": ["autogroup:shared"], "dst": ["*"], "ip": ["443"]}
   ```

   The Tailscale docs give this pattern: https://tailscale.com/docs/features/sharing
4. Share cb-lab with each client's email from the Machines page. Shared users reach only the machines shared with them.
5. Once, from a second Tailscale account, open a deployed project URL. Tailscale does not state in its docs that shared users can open a Serve URL, so confirm it before the first real client.

## Scripts

All scripts except `deploy.sh` take the project name, which is the folder name of the project on your laptop. It matches `[a-z0-9-]`, up to 40 characters.

| Script | What it does |
| --- | --- |
| `setup-server.sh` | Installs and configures everything on cb-lab. |
| `deploy.sh <project-dir>` | Creates the project on cb-lab on the first run, pushes `main` and all tags to the `cb-lab` remote, and prints the client link, login and password. It refuses a dirty working tree, a missing commit, and any other git remote. |
| `feedback.sh <project> list` | Prints open comments as JSON lines. |
| `feedback.sh <project> reply <id> <resolved\|wont_fix\|in_progress> <text>` | Replies as Claude and sets the status. |
| `offline.sh <project>` | Makes the site and its comment API answer 503. Nothing is deleted. |
| `online.sh <project>` | Undoes `offline.sh`. |
| `cleanup.sh <project>` | Removes the served files, password, invites and review. Moves the comments next to the git repo. Keeps the git repo. Safe to run twice. |

## Where things are on cb-lab

| Path | Content |
| --- | --- |
| `~/git/prototypes/<project>.git` | Private bare repo, the only copy of the prototype history. |
| `~/git/prototypes/<project>.secrets` | Password and invite tokens, mode 600. Removed by `cleanup.sh`. |
| `~/git/prototypes/<project>.comments.json` | Comments kept by `cleanup.sh`. |
| `/srv/prototypes/<project>` | Served checkout. |
| `/srv/prototypes-offline/<project>` | Exists while the project is offline. |
| `/etc/nginx/prototypes/<project>.htpasswd` | nginx password file, also marks the project as existing. |
| `/etc/annotate/reviews.json`, `/var/lib/annotate/` | annotate reviews and comments. |
| `/etc/nginx/conf.d/prototypes.conf`, `/etc/systemd/system/annotate.service` | Written by `setup-server.sh`. |

## Operations

- Logs: `ssh cb-lab journalctl -u annotate -n 50` and `ssh cb-lab sudo tail /var/log/nginx/access.log`.
- Restart the comment server: `ssh cb-lab sudo systemctl restart annotate`. Comments stay on disk, and sessions restart on the next page load.
- Upgrade annotate: change the tag and sha256 in `setup-server.sh` and the version in the two templates of the skill, then rerun the setup.
