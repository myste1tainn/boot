# Runbook — Container runtime: Podman ➜ Docker CLI + Colima (macOS)

**Status:** applied on the primary laptop **2026-10-08**.
**Audience:** me, or a Claude instance on another machine, repeating this migration.
**Goal:** run Docker tooling on macOS **without Docker Desktop** (its licence is paid for an org of
our size), using the Apache-2.0 **Docker CLI** against an **MIT-licensed Colima** Linux VM.

> Read this top to bottom before running anything. Steps 0–2 are the migration; step 7 is the
> ongoing cheat-sheet. If you are setting up a *fresh* laptop with nothing installed, skip to
> **Fresh-machine path** at the bottom — `bootstrap.sh` already does all of this.

---

## Why Colima (and not the alternatives)

| Option | Licence | Verdict |
|---|---|---|
| **Docker Desktop** | **Paid** for orgs >250 staff or >$10M revenue | **Rejected** — the whole point of this migration |
| **Colima** (lima + docker engine) | MIT (Colima), Apache-2.0 (docker CLI/engine) | **Chosen** — CLI-driven, `brew`-installable, no GUI, no licence |
| Rancher Desktop | Apache-2.0 | Viable, but a GUI/Electron app we don't need |
| OrbStack | **Paid** for commercial use | Rejected, same trap as Desktop |
| Podman | Apache-2.0 | What we're leaving — the ecosystem assumes `docker`, and tooling (minikube, testcontainers) treats docker as the default |

**Key licence point:** the Docker *CLI, engine and Compose* are open source and free. Only *Docker
Desktop* carries the paid licence. Installing `brew install docker` does **not** install Desktop.

---

## 0. Pre-flight — inventory before destroying anything

```bash
podman machine list                 # how many VMs, how big
podman ps -a                        # anything still running?
podman volume ls                    # data that would be lost
du -sh ~/.local/share/containers    # disk the VMs occupy
minikube profile list               # which profiles use --driver=podman
```

Record the answers. On the primary laptop (2026-10-08) this was: 2 VMs (100 GiB + 80 GiB, **89 GB**
on disk), 11 containers all **exited** for ≥4 months, 11 volumes all stale, 2 minikube profiles on
the podman driver (one already broken).

**Decide explicitly, and write the answer down:**

1. **Podman** — full removal, or keep as fallback?
2. **Volume data** — migrate, or start clean? Nothing stale is worth migrating; anything live must be
   exported *before* the VM is deleted (see step 6).
3. **VM size** — see step 2.

### ⚠️ The landmine: a stale `minikube docker-env` in the shell profile

Check this **first**. It silently breaks the new setup in a way that looks like a Colima bug:

```bash
grep -nE 'DOCKER_HOST|DOCKER_TLS_VERIFY|DOCKER_CERT_PATH|MINIKUBE_ACTIVE_DOCKERD' ~/.zshrc
```

On the primary laptop `~/.zshrc` (→ `~/.boot/zsh/zshrc`) contained a pasted `eval $(minikube
docker-env)`:

```sh
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://127.0.0.1:44459"      # ← points at a dead minikube dockerd
export DOCKER_CERT_PATH="$HOME/.minikube/certs"
export MINIKUBE_ACTIVE_DOCKERD="minikube"
```

**`DOCKER_HOST` overrides the docker context**, so every `docker` command would have gone to a port
that no longer exists. **Delete all four lines.** Colima warns about this on startup
(`DOCKER_HOST environment variable overrides the active context`) — do not ignore that warning.

> Keep `export ENV_FILE=.env.docker-local` if present — unrelated to the runtime.

**Already-open terminals keep the stale values.** Deleting the lines stops them being *set*; it cannot
*unset* what a running shell already exported. Every pre-existing tab (and any editor/agent session
started from one) will still fail with `Cannot connect to the Docker daemon at tcp://127.0.0.1:44459`.
Open a new tab, or in each old one:

```bash
unset DOCKER_HOST DOCKER_TLS_VERIFY DOCKER_CERT_PATH MINIKUBE_ACTIVE_DOCKERD
```

When verifying the fix, test with a clean environment — a plain `zsh -l` inherits the parent's env and
will look broken even when the config is correct:

```bash
env -i HOME="$HOME" TERM=xterm USER="$USER" SHELL=/bin/zsh /bin/zsh -lic \
  'docker context show && docker run --rm alpine echo ok'
```

Note the file may be a **symlink** into a dotfiles repo (`~/.zshrc` → `~/.boot/zsh/zshrc`); BSD
`sed -i` refuses to edit through a symlink with `in-place editing only works for regular files`.
Edit the resolved path: `readlink -f ~/.zshrc`.

---

## 1. Install

```bash
brew install colima docker docker-compose docker-buildx
```

- `docker` = CLI only (**not** Desktop).
- `docker-compose` = the Compose **v2 plugin** → `docker compose`, never `docker-compose`.
- `docker-buildx` = BuildKit builder.

### Register the Homebrew CLI plugins (required — easy to miss)

Homebrew installs compose/buildx where the docker CLI does not look by default, so `docker compose`
fails with `not a docker command` until you add `cliPluginsExtraDirs`:

```bash
mkdir -p ~/.docker
cat > ~/.docker/config.json <<'EOF'
{
  "cliPluginsExtraDirs": [
    "/opt/homebrew/lib/docker/cli-plugins"
  ]
}
EOF
```

If `~/.docker/config.json` already exists, **merge** the key instead of overwriting (it may hold
`credHelpers`/`auths`).

---

## 2. Create the VM

Sizing used on the primary laptop (host: **M4 Pro, 12 cores, 48 GB**) — leaves 32 GB for macOS:

```bash
colima start --cpu 8 --memory 16 --disk 100 --vm-type vz --vz-rosetta --mount-type virtiofs
```

| Flag | Why |
|---|---|
| `--vm-type vz` | Apple Virtualization.framework — faster and lighter than QEMU (needs macOS 13+) |
| `--vz-rosetta` | runs `linux/amd64` images via Rosetta instead of slow QEMU emulation |
| `--mount-type virtiofs` | fastest host↔VM filesystem sharing (requires `vz`) |
| `--disk 100` | **grown later only by recreating the VM** — err generous |

Scale down for a smaller host, e.g. `--cpu 6 --memory 12 --disk 80`.

Flags are persisted in `~/.colima/default/colima.yaml`; later `colima start` needs no flags.

---

## 3. Verify (do not skip — these are the things that actually break)

```bash
colima status
docker context ls                 # 'colima' must carry the *
docker version                    # Client + Server both reported
docker compose version            # plugin wiring from step 1
docker buildx version

docker run --rm alpine uname -m                              # → aarch64
docker run --rm --platform linux/amd64 alpine uname -m       # → x86_64  (Rosetta)
```

Then a compose stack exercising bind mounts, named volumes and published ports — **from a directory
under `$HOME`** (see the mount caveat below):

```bash
mkdir -p ~/colima-smoke/site && echo '<h1>ok</h1>' > ~/colima-smoke/site/index.html
cd ~/colima-smoke
cat > compose.yaml <<'EOF'
services:
  web:
    image: nginx:alpine
    ports: ["18080:80"]
    volumes: [./site:/usr/share/nginx/html:ro]
  db:
    image: postgres:16-alpine
    environment: { POSTGRES_PASSWORD: smoke }
    volumes: [pgdata:/var/lib/postgresql/data]
volumes: { pgdata: }
EOF
docker compose up -d --wait
curl -s localhost:18080            # bind mount + port publish
docker compose exec -T db psql -U postgres -c 'select 1'   # named volume
docker compose down -v && cd ~ && rm -rf ~/colima-smoke
```

### ⚠️ Only `$HOME` is bind-mountable — and failure is *silent*

Colima virtiofs-mounts **`$HOME` only**. A bind mount of a path outside it (`/private/tmp`, `/opt`,
`/usr/local`, …) does **not** error — the path is auto-created **empty inside the VM**, so the
container sees an empty directory. The symptom is confusing: nginx returns **403 Forbidden**,
configs appear missing, databases look freshly initialised.

This was hit during the migration: the smoke test was first run from a scratch dir under
`/private/tmp` and returned 403; the identical compose file under `$HOME` worked immediately.

**Rule: keep repos and all compose bind mounts under `$HOME`.** Verify what the VM actually sees:

```bash
colima ssh -- mount | grep virtiofs
```

To mount an extra path you must recreate the VM (`colima delete && colima start --mount /extra:w`).

---

## 4. Point minikube at Colima

Do this **while podman still exists**, so the old podman-driver profiles can be deleted cleanly:

```bash
minikube delete --all                 # removes podman-driver profiles
minikube config set driver docker
minikube start --driver=docker
kubectl get nodes                     # wait for STATUS=Ready (~60s; NotReady at first is normal, CNI)
```

> **Cosmetic:** minikube prints `Using Docker Desktop driver with root privileges`. It is **not**
> Docker Desktop — minikube just labels any docker daemon that way. Harmless; ignore it.

minikube then runs as a container *inside* the Colima VM (`docker ps` shows `minikube`), so the
Colima VM must be sized to hold the cluster — hence 16 GB, not 4.

---

## 5. Rewrite the Podman mandates in the dotfiles

Both repos are synced across laptops, so this is what makes the change stick:

**`~/.boot`:**
- `Brewfile` — replace `podman`/`podman-compose` with `colima`, `docker`, `docker-compose`, `docker-buildx`
- `bootstrap.sh` — replace the `podman machine init/start` block with the Colima block + the
  `cliPluginsExtraDirs` writer; `minikube config set driver docker`. Needs a `warn()` helper if absent.
- `zsh/zshrc` — the four `DOCKER_*`/`MINIKUBE_ACTIVE_DOCKERD` lines (step 0)
- `CLAUDE.md` — the `install-tools.sh` tool list

**`~/.boot/dotclaude` (submodule, → `~/.claude`):**
- `dotclaude/CLAUDE.md` — the **`## Container Runtime`** section (the global mandate) + the
  `dev-tools/` and `platforms/` lines
- `dotclaude/rules/coding-standards.md` — the deployable contract (`Containerfile` ➜ `Dockerfile`), E2E line
- `dotclaude/rules/workspace-layout.md` — the `dev-tools/` tree comment
- `dotclaude/skills/devops/SKILL.md` — local stack, `--driver=docker`, build commands, guardrails
- `dotclaude/agents/developer.md`, `dotclaude/agents/qa.md` — the "Podman only" guardrails
- `dotclaude/templates/devops/` — `scripts/up.sh` (colima preflight, `docker build`, drop the
  `localhost/` image prefix), `README.md`, `platform.yaml`, `jobs/migrate.job.yaml`,
  `kustomize/overlays/local/kustomization.yaml`, `kustomize/base/_service.template.yaml`

**Stale per-project memories** under `dotclaude/projects/*/memory/` that assert "uses Podman" must be
updated, and ones whose *premise* is now false must be **deleted** — e.g. a
`podman-container-compatibility` feedback memory saying "avoid BuildKit syntax, cannot use Docker"
is now actively harmful, since buildx makes BuildKit the default. Remove its `MEMORY.md` line too.

Verify: `grep -rniE 'podman' ~/.boot --include='*.md' --include='*.sh' --include='Brewfile'`
(hits under `dotclaude/projects/*/*.jsonl` are historical chat transcripts — ignore them).

### ⚠️ Not all of these files are in git — check before trusting the sync

As of 2026-10-08 in the `dotclaude` submodule:

- **Tracked** (syncs once committed): `dotclaude/CLAUDE.md`, `dotclaude/agents/developer.md`,
  `dotclaude/agents/qa.md`
- **UNTRACKED** — exist only on the laptop that made them, so a second machine does **not** have
  them at all: `dotclaude/rules/coding-standards.md`, `dotclaude/rules/workspace-layout.md`,
  `dotclaude/rules/git-platform-cli.md`, `dotclaude/rules/project-claude-md.md`,
  `dotclaude/rules/taxonomy.md`, `dotclaude/rules/ticket-status-comments.md`,
  `dotclaude/skills/devops/`, `dotclaude/templates/devops/`
- **Deliberately gitignored**: `dotclaude/projects/` (session transcripts + per-project memory —
  `.gitignore` says committing it would leak session content)

So on the other laptop: the `Brewfile` / `bootstrap.sh` / `zshrc` / `CLAUDE.md` changes arrive through
git, but the **devops skill, the templates and most `rules/` files must be `git add`-ed first** or they
will never arrive. And because `projects/` is ignored, that machine keeps its **own** stale
per-project memories — re-run the memory cleanup there:

```bash
grep -rniE 'podman' ~/.claude/projects/*/memory/ 2>/dev/null
```

---

## 6. Remove Podman

**Export any volume you still need first** — deleting the machine destroys all of it:

```bash
podman run --rm -v <vol>:/data -v "$HOME/backup:/backup" alpine \
  tar czf /backup/<vol>.tgz -C /data .
# restore later under docker:
docker run --rm -v <vol>:/data -v "$HOME/backup:/backup" alpine \
  tar xzf /backup/<vol>.tgz -C /data
```

Then:

```bash
podman machine stop <name>
podman machine rm -f <name>            # repeat per machine — this reclaims the disk
brew uninstall podman podman-compose
rm -rf ~/.local/share/containers       # VM images + SSH keys (~957 MB left after rm)
```

**Do NOT blindly delete `~/.config/containers`** — `auth.json` there holds **registry credentials**.
On the primary laptop it held a login for `asia-southeast1-docker.pkg.dev` (Google Artifact
Registry). It was left in place. Give docker its own credential helper instead of copying tokens:

```bash
gcloud auth configure-docker asia-southeast1-docker.pkg.dev
# equivalently, merge into ~/.docker/config.json:
#   "credHelpers": { "asia-southeast1-docker.pkg.dev": "gcloud" }
```

`docker-credential-gcloud` ships with the gcloud SDK — confirm with `command -v docker-credential-gcloud`.

**Side-fix required for this to work (`zsh/zshrc`):** the lazy `gcloud()` loader was broken by a
late-binding bug — `_gcloud_sdk` was `unset` at shell startup, but the function body dereferences it at
*call* time, so both `source` paths collapsed to `/path.zsh.inc` and every `gcloud` invocation failed.
Renamed to `GCLOUD_SDK_HOME` and dropped the `unset`. Without this, `docker pull` from Artifact
Registry fails even with `credHelpers` set correctly, because the helper shells out to `gcloud`.

If the helper returns `Reauthentication failed`, that is only an expired session: `gcloud auth login`.

**Result on the primary laptop: 89 GB reclaimed** (460 GB volume went to 189 GB free).

---

## 7. Day-to-day cheat-sheet

| Task | Command |
|---|---|
| Start / stop the engine | `colima start` / `colima stop` |
| Is it running? | `colima status` |
| `docker: Cannot connect to the Docker daemon` | `colima start` — **never** install Docker Desktop |
| Resize CPU/RAM | `colima stop && colima start --cpu N --memory N` |
| Resize **disk** | requires `colima delete` + recreate (images are lost) |
| Shell into the VM | `colima ssh` |
| Reset everything | `colima delete && colima start …` (step 2) |
| Start at login | `brew services start colima` |
| Free disk inside the VM | `docker system prune -a --volumes` |

**Translation table** for old muscle memory / old scripts:

| Podman | Docker |
|---|---|
| `podman build` | `docker build` |
| `podman compose up -d` | `docker compose up -d` |
| `podman machine start` | `colima start` |
| `podman machine list` | `colima list` |
| `minikube start --driver=podman` | `minikube start --driver=docker` |
| `Containerfile` | `Dockerfile` (docker does **not** read `Containerfile` by default — pass `-f Containerfile`) |

**Gotchas, in the order they bite:**

1. `DOCKER_HOST` in a shell profile overrides the context — never set it (step 0).
2. `docker compose` needs `cliPluginsExtraDirs` under Homebrew (step 1).
3. Bind mounts outside `$HOME` silently resolve to **empty** dirs (step 3).
4. minikube claims "Docker Desktop driver" — cosmetic (step 4).
5. `Containerfile` is not auto-detected by `docker build` — rename, or pass `-f`.
6. Colima is **not** running after a reboot unless `brew services start colima`.

---

## Outstanding follow-up (NOT done by this migration)

**12 project repos still invoke `podman` and will now fail** with `command not found` — 75 files as
of 2026-10-08. They are separate git repos and each needs its own branch/commit, so they were left
alone deliberately:

| Files | Repo |
|---|---|
| 27 | `workspace/cmpr3` |
| 10 | `workspace/cmpr3-spec-export` |
| 8 | `workspace/docker-apps` (n8n `bootstrap.sh` even **installs** podman) |
| 7 | `workspace/data-n-ai-coe` |
| 7 | `workspace/cape` |
| 6 | `personal-workspace/bear-bull` |
| 5 | `workspace/release-3-root` |
| 1 each | `ai-workshop-retail-banking`, `ai-workshop-retail-banking-salvage`, `va-evaluation`, `promptfoo-testing`, `promptfoo-va` |

Re-scan with:

```bash
rg -l --no-messages -g '!node_modules' -e '\bpodman(-compose)?\b' ~/workspace ~/personal-workspace
```

Most are a mechanical `podman` ➜ `docker` / `podman compose` ➜ `docker compose` swap, plus replacing
`podman machine start` with `colima start`. Fix each repo on its own branch, on demand.

---

## Fresh-machine path (nothing installed yet)

`bootstrap.sh` in this repo already encodes all of the above — no manual steps:

```bash
git clone git@github.com:myste1tainn/boot.git ~/.boot
cd ~/.boot && ./bootstrap.sh
```

It installs the `Brewfile` (colima + docker + compose + buildx), writes
`~/.docker/config.json` with `cliPluginsExtraDirs`, creates the Colima VM
(override with `COLIMA_CPU` / `COLIMA_MEMORY` / `COLIMA_DISK`), and sets
`minikube config set driver docker`. Then run step 3's verification.

```bash
COLIMA_CPU=6 COLIMA_MEMORY=12 COLIMA_DISK=80 ./bootstrap.sh   # smaller host
```
