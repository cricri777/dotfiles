# UI prototypes for clients

`/cricri-ui-prototype` turns a client's example sites into 3 HTML variants, hosts them privately on cb-lab, and iterates on the client's inline comments until they approve one. Server details are in the [playbook](../playbooks/cb-lab-prototypes/README.md).

The scripts live in the dotfiles repo. In a terminal, set this once per shell:

```bash
PB=~/git/perso/dotfiles/playbooks/cb-lab-prototypes
```

## Before the first project

Do the [one-time setup](../playbooks/cb-lab-prototypes/README.md#one-time-setup) once. Then check:

```bash
ssh cb-lab true && echo "cb-lab reachable"
chromium --version
```

## For each project

1. Collect the client's example sites and PNG screenshots. Pick a folder outside any git repo, for example `~/prototypes/acme`. The folder name is the project name, in lowercase letters, digits and hyphens.
2. In Claude Code, run:

   ```
   /cricri-ui-prototype new ~/prototypes/acme https://example-1.com https://example-2.com ~/Downloads/inspiration.png
   ```

   Claude asks for the business name, pages and language if they are missing. It builds `brief.md`, 3 variants and a gallery, and checks screenshots at 375, 768 and 1440 px.
3. Open `~/prototypes/acme/index.html` in a browser to look at the 3 variants yourself.
4. Answer yes when Claude asks to deploy. It prints a client link, a login and a password.
5. Share cb-lab with the client, once per client: in the Tailscale admin console, open Machines, the menu of cb-lab, Share, and enter their email. The client accepts the invite and installs Tailscale with their own account.
6. Send the client a message like this, translated to their language:

   > Install Tailscale and accept the invite for cb-lab. Open this link: `<client link>`. Log in with `<login>` and `<password>`. Open each variant, click the Review button at the bottom right, and add pins, highlights or drawings with your comments. On the first page, comment to tell me which variant you prefer.

## For each round

1. Wait for the client's comments. To look at them yourself:

   ```bash
   $PB/feedback.sh acme list
   ```

2. Run:

   ```
   /cricri-ui-prototype iterate ~/prototypes/acme
   ```

   Claude reads the comments and writes `feedback/round-N.md` with the preferred variant and one line per comment. Read it and approve it, or tell Claude what to change.
3. Claude builds 3 new variants from the preferred one, shoots and checks them, tags `round-N`, deploys, and replies to every comment. The client sees the replies and statuses in the Review panel.
4. Tell the client the new round is ready. They reuse the same link, login and password.

## When the client approves

```
/cricri-ui-prototype handoff ~/prototypes/acme b
```

Claude keeps variant B, writes `handoff.md` for the developer, tags `approved` and deploys. The developer gets the code with:

```bash
git clone cb-lab:git/prototypes/acme.git
```

## Pause, resume and finish

| Goal | Command |
| --- | --- |
| Take the site offline for now | `/cricri-ui-prototype offline ~/prototypes/acme` or `$PB/offline.sh acme` |
| Bring it back | `/cricri-ui-prototype online ~/prototypes/acme` or `$PB/online.sh acme` |
| Remove everything except the git repo | `/cricri-ui-prototype cleanup ~/prototypes/acme` or `$PB/cleanup.sh acme` |
| Delete the git repo for good | Run the `rm -rf` command that `cleanup.sh` prints. Only an admin does this. |
| Stop a client from reaching cb-lab | Remove their share in the Tailscale admin console. |

## When something goes wrong

| Symptom | Cause and fix |
| --- | --- |
| The client sees 401 | Wrong login or password. Run `$PB/deploy.sh ~/prototypes/acme` again, it reprints the link, login and password. |
| The client sees 503 | The project is offline. Run `online.sh`. |
| The client sees 404 | The project was never deployed, or `cleanup.sh` ran. |
| The client cannot reach cb-lab at all | The share is not accepted, Tailscale is off on their machine, or the grant blocks port 443. |
| The Review button is missing | The client's browser cannot load the jsDelivr CDN. Try another network. |
| The client's comments do not show up for you | Ask the client to open the client link with `?an_invite=` once. Then run `feedback.sh acme list` again. |
| `deploy.sh` says uncommitted changes | Commit in the project folder, then deploy again. |
| `deploy.sh` says remove the remote | The folder has a git remote other than `cb-lab`. Prototypes live only on cb-lab. |
| `deploy.sh` says push rejected | A kept repo with the same name and another history exists on cb-lab, left by an earlier project. Pick another name, or ask an admin to delete the old repo. |
| `shoot.sh` says chromium is not installed | Run `sudo pacman -S chromium`. |
| `ssh cb-lab` fails | Run `tailscale status` and check that cb-lab is active. |

## Limits

- One password per project, shared by everyone at that client.
- Everyone at the client comments as `Client`, and sees every client comment.
- Screenshots cover the first 1200 px of each page. Claude also reads the HTML for the rest.
- Tailwind and annotate.js load from the jsDelivr CDN, so the prototype needs internet. This is fine for prototypes and not for the final site.
- Restarting the comment server, which happens when a project is added or cleaned up, ends active comment sessions. The next page load starts a new one from the invite stored in the browser.
