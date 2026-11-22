---
name: cricri-ui-prototype
description: Turn a client's example sites or PNG screenshots into 3 static HTML variants, host them privately on cb-lab, collect inline comments, and iterate until the client approves one.
argument-hint: "new <project-dir> <url-or-png>... | iterate <project-dir> | handoff <project-dir> <a|b|c> | offline|online|cleanup <project-dir>"
disable-model-invocation: true
---

# cricri-ui-prototype

Task: $ARGUMENTS

The first word of the task is the command. Stop and print this usage when it is missing or unknown.

## Locate the tools

```bash
SKILL_DIR="$(readlink -f ~/.claude/skills/cricri-ui-prototype)"
PB="$(cd "$SKILL_DIR/../../.." && pwd)/playbooks/cb-lab-prototypes"
SHOOT="$SKILL_DIR/scripts/shoot.sh"
```

The user guide is `docs/ui-prototype.md` in the dotfiles repo.

## Rules

- Write no comments in the HTML.
- The page copy is in the client's language. Everything else is in English.
- `<project-dir>` is the root of its own git repo, and its name matches `[a-z0-9-]`. It is never inside another repo.
- Client work is versioned only on cb-lab through `$PB/deploy.sh`. Never add another remote, never push to GitHub, never commit client files to the dotfiles repo.
- Never delete the bare git repo on cb-lab. `cleanup` leaves it for the admin.
- Never copy images, logos or text from the reference sites. Use their layout, color and tone as input. Use Tailwind color blocks or inline SVG as placeholders for images.
- Ask the user before the first `deploy.sh` of a project, and before any edit in `iterate`.

## Project layout

```
<project-dir>/
  brief.md            references, business facts, direction of each variant
  references/         PNG files and screenshots of the reference sites
  index.html          gallery of the 3 current variants, built from templates/gallery.html
  variants/a|b|c/     one folder per variant, pages inside, built from templates/page.html
  screens/a|b|c/      375.png, 768.png, 1440.png per variant, plus screens/gallery/
  feedback/round-N.md decisions for each round
```

Each round has exactly 3 variants. A new round replaces the 3 folders. The git tags `round-N` keep every earlier round.

Fill the placeholders of the templates with `sed` or a small script: `__LANG__`, `__TITLE__`, `__PROJECT__`, `__CONTENT__`, and in the gallery `__ROUND__` and `__DIRECTION_A__` to `__DIRECTION_C__`. Do not change the two script tags. Link pages inside a variant with relative paths.

## new `<project-dir> <url-or-png>...`

1. Stop if `<project-dir>` exists and is not empty, or if its name is invalid. Create it and run `git init -b main`.
2. Read each reference.
   - For a URL, fetch the page with the web-fetch agent and run `$SHOOT <url> <project-dir>/references/<name>`.
   - For a PNG file, read the image and copy it into `references/`.
3. Write `brief.md`: per reference, the colors, fonts, layout, tone and what to borrow. Ask the user for the business name, the pages, the copy language and the goal of the site when the arguments do not give them.
4. Build 3 variants of the home page. Each takes a clearly different direction, such as layout, density, color and type. Write the direction of each in `brief.md`. Use real, specific copy, a visible call to action, and responsive classes for 375, 768 and 1440 px.
5. Build the gallery. Each card shows the screenshot and the one-line direction.
6. Run `$SHOOT <page> <project-dir>/screens/<variant>` for each variant page, and for the gallery into `screens/gallery`. Read the PNG files. Fix overflow, overlap and unreadable contrast, then shoot again.
7. Commit and tag `round-0`.
8. Ask the user, then run `$PB/deploy.sh <project-dir>`. Print the client link, login and password from its output, and say that the user must share cb-lab with the client in Tailscale. The steps are in `docs/ui-prototype.md`.

## iterate `<project-dir>`

1. Run `$PB/feedback.sh <project> list`. The project name is the folder name.
2. N is the highest `round-*` tag number plus 1, from `git tag -l 'round-*'`. Write `feedback/round-N.md`. It names the preferred variant and the preferences the client stated, then has one line per comment with the planned change or the reason for refusing it. Ask the user to name the preferred variant when the comments do not. The user approves the file before any edit.
3. Build 3 new variants that start from the preferred variant. Each applies the stated preferences and differs from the other 2 on a point the client has not settled, such as the hero layout or the color accent. Add pages when the client asks for them, in all 3 variants. Update `brief.md` and the gallery, and set `__ROUND__` to N.
4. Shoot and read the screenshots as in `new`. Commit, tag `round-N`, and run `$PB/deploy.sh <project-dir>`.
5. For each comment run `$PB/feedback.sh <project> reply <comment-id> <resolved|wont_fix|in_progress> "<what changed or why not>"`.
6. Tell the user the client link and that the round is ready.

## handoff `<project-dir> <a|b|c>`

The client approved one variant.

1. Move `variants/<v>/*` to the project root in place of the gallery, and delete `variants/` and the other `screens/` folders.
2. Write `handoff.md` for the developer: design tokens (colors, fonts, spacing scale), the page list, the repeated components with their Tailwind classes, the copy that is placeholder, and the images to replace.
3. Commit, tag `approved`, and run `$PB/deploy.sh <project-dir>`.

## offline, online, cleanup `<project-dir>`

Run `$PB/offline.sh`, `$PB/online.sh` or `$PB/cleanup.sh` with the folder name. Print the output of `cleanup.sh` in full, because it ends with the command an admin runs to delete the git repo.
