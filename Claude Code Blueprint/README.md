# Obsidian workflow · a second brain for Claude

A way of working with AI you can drop into any project. Copy this folder's contents into the target project, fill the `{{PLACEHOLDERS}}`, run setup, delete what you don't use.

> This file just describes the system. Once you copy it into the target project, you can delete it.
> 🌎 Não fala inglês? Veja [README.pt-BR.md](README.pt-BR.md).

---

## 🧠 Mental model

The main idea: just one truth, serving both the AI and the user.

The two principles that make it work:

1. **Index + description** Each folder has an index that points to the files with one description line. The AI reads that index, then picks the right file to open, instead of reading a whole `.md` at once. You navigate the same way.
2. **Track the changes** It saves the "before" of every edit in `history/`. The AI doesn't read this folder, it's just there for you to track the changes.

For the repetitive rituals (update the roadmap, close the session, save a memory) there are **skills**: short commands you type (`/end`, for example) that the AI also fires on its own when the moment fits.

---

## 📂 What's here

```
_BLUEPRINT_WORKFLOW/
├── README.md                       ← this file (delete it when you plug into a project)
├── README.pt-BR.md                 ← Portuguese version of this file
├── CLAUDE.md                       ← the project's work rules + the AI's starting index
├── .claude/
│   ├── settings.json               ← registers the hooks + declares the superpowers plugin
│   ├── setup.ps1 / setup.sh        ← wire memory into the repo + the .gitignore block (Windows / Mac-Linux)
│   ├── hooks/
│   │   ├── run-hook.cmd            ← cross-OS dispatcher (.ps1 on Windows, .sh on Mac/Linux)
│   │   ├── snapshot.ps1 / .sh      ← freeze the "before" into history/
│   │   └── remind-map.ps1 / .sh    ← after a code edit, nudge to update the map
│   └── skills/                     ← the workflow commands (see §5)
│       ├── start/ done/ end/ remember/ map/ writeplan/ debloat/ setup/   (you trigger)
│       └── check-map/ check-plan/ fix-links/                              (automatic)
└── project_brain/                  ← the shared brain (you + the AI)
    ├── Vision.md                   ← YOUR vision (you write, the AI reads)
    ├── context.md                  ← stack, principles, project rules (indexed by CLAUDE.md)
    ├── plan/                       ← the AI's technical plan
    │   ├── plan_index.md           ← hub (navigation only)
    │   ├── plan_summary.md         ← overview + pointers (reading entry)
    │   ├── plan_why.md             ← the what/why (critical read, open questions)
    │   └── plan_tech.md            ← the how (architecture, decisions, metrics)
    ├── roadmap/
    │   ├── roadmap_index.md        ← how the roadmap works
    │   ├── roadmap.md              ← ACTIVE checklist (only what's left)
    │   └── roadmap_log.md          ← append-only log
    ├── next_step.md                ← one active item (overwritten each time)
    ├── code_map/
    │   └── map_index.md            ← code map index (method lives in /map)
    ├── history/                    ← automatic snapshots (the AI never reads it)
    ├── notes/                      ← your notes/scratch space (the AI reads only when you ask)
    └── memory/                     ← auto-memory (linked into Claude Code, see §7)
        ├── MEMORY.md               ← memory index
        └── _TEMPLATE_*.md          ← user / feedback / project / reference
```

---

## 🚀 1. Setup

> ⚡ **Automatic:** drop the whole `Claude Code Blueprint/` folder into the project and paste:
> > *"Read `Claude Code Blueprint/.claude/skills/setup/SKILL.md` and set this up in this project, reconciling with whatever is already here and preserving my content."*
>
> The AI installs it fresh (or upgrades it in place if a version is already there), moves the files to the root, runs setup, asks what language you want, and deletes the blueprint folder at the end. Anything already in your project stays where it is. Then reopen the session so the commands (`/start`, `/end`...) load.

Prefer it by hand? In order:

**1. Copy** `CLAUDE.md`, `.claude/`, and `project_brain/` to the target project's root. (The contents, not the `Claude Code Blueprint/` folder itself. `.claude/` and `CLAUDE.md` have to sit at the root or Claude Code won't find them.)

**2. Fill the `{{PLACEHOLDERS}}`** in `CLAUDE.md` and `project_brain/context.md`.

**3. Run setup** (wires memory into the repo + the `.gitignore` block):
   - Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File .claude\setup.ps1`
   - Mac/Linux: `bash .claude/setup.sh`

**4. (Recommended) Connect Obsidian over MCP** (§9). Gives the AI eyes inside the vault.

**5. Write your vision** in `project_brain/Vision.md`. The what and the why, no need to be technical.

**6. Ask the AI** (or use the skills) to generate, from your vision plus a read of the code: the technical plan (`/writeplan`), the code map (`/map`), then the `roadmap`.

**7. Set `next_step.md`** to one concrete action.

**8. Check the hook**: edit any living doc and watch a snapshot land in `project_brain/history/`.

> ⚠️ **Already have your own notes or an old workflow folder?** It stays where it is, setup never touches it. After the install, just ask Claude to read it and fold the useful parts into the structure (vision, plan, roadmap, memory). It adapts the content with your OK, no rigid mapping. Full procedure: `.claude/skills/setup/SKILL.md`.

> ⚠️ **Existing project with a `.gitignore`:** setup appends the Claude block, it doesn't clobber. If your team versions a `CLAUDE.md`, decide whether to hide it (the default block ignores `CLAUDE.md`; edit the block in the setup script to keep it versioned).

> 🦸 **superpowers plugin (comes declared):** `.claude/settings.json` already declares `superpowers@claude-plugins-official`. When you trust the project folder, Claude Code asks to install the marketplace + plugin. Once installed, it loads the `using-superpowers` skill at the start of every session. No prompt? Run `claude plugin install superpowers@claude-plugins-official`.

---

## 🌎 2. Language

The blueprint ships in **English**. At setup, `/setup` asks which language you want and **localizes the install**: it translates the prose you read and edit (the `project_brain/` docs, `CLAUDE.md`, the skill triggers) and the folder, file, and command names too, rewriting every reference so links and hooks keep working. A handful of names that Claude Code and the engine require stay English (`.claude/`, the hook scripts, `settings.json`, the `memory/` folder). So your mom can run it fully in Portuguese, a German in German, all from one source.

---

## 🔖 3. Placeholders

| Placeholder | What it is |
|-------------|------------|
| `{{PROJECT_NAME}}` | short project name |
| `{{PROJECT_DESCRIPTION}}` | one line on what the project does |
| `{{USER}}` | what the AI calls you |
| `{{PRINCIPLES}}` | priorities when things conflict |
| `{{STACK}}` | language/runtime/environment |
| `{{SPECIFIC_RULES}}` | rules unique to this project |

> `STACK`, `PRINCIPLES`, and `SPECIFIC_RULES` live in `project_brain/context.md`; the rest in `CLAUDE.md`.

---

## 🗂️ 4. The living files

| File | Who writes | What for |
|------|-----------|----------|
| `Vision.md` | You | Your vision: the what and the why. The AI reads it and derives the plan. |
| `context.md` | You | Stack, principles, project-specific rules. |
| `plan/plan_summary.md` | AI | Entry to the technical plan: short overview + pointers. |
| `plan/plan_why.md` | AI | Critical read of your vision, risks, open questions. |
| `plan/plan_tech.md` | AI | Architecture by phase, technical decisions, metrics. |
| `roadmap/roadmap.md` | AI | Active checklist, only what's left. |
| `roadmap/roadmap_log.md` | AI | Append-only log. The AI only writes here. |
| `next_step.md` | AI | One active item. Done, it's overwritten with the next. |
| `code_map/map_index.md` | AI | Code state: top view + pointers to fragments. |
| `memory/` | AI (auto) | Persistent memory across sessions (§7). |
| `notes/` | You | Your notes/scratch space. The AI reads it only when you ask. |
| `history/` | Hook (auto) | Frozen versions. The AI never reads it. |

---

## 🛠️ 5. Skills / commands

A skill works two ways at once: you type `/name`, and the AI fires it on its own when the context matches its `when_to_use`. The skills carry the procedure; the rules in `CLAUDE.md` are the short baseline.

**Rituals (you trigger, or the AI when it recognizes the moment):**

| Command | What it does |
|---------|--------------|
| `/setup` | Onboarding: install or upgrade the blueprint in a project. Use it when you plug the folder in. |
| `/start` | Read-only orientation: where we stopped + the next step. |
| `/done` | Finished a task: log it, prune the roadmap, set the next step. |
| `/end` | End of session: update the map, log, roadmap, next_step, sweep dead links. |
| `/remember` | Save a memory in the right format + index it. |
| `/map` | (Re)build the code map. |
| `/writeplan` | Derive or update `plan/` from your `Vision.md`. |
| `/debloat` | Trim `project_brain/`: cut redundancy, prune stale, fragment big files, fix links. |

**Automatic (the AI fires them, you don't call them):**

| Skill | When the AI pulls it |
|-------|----------------------|
| `check-map` | about to touch code it doesn't know; reads the map first |
| `check-plan` | about to change architecture or a settled decision; checks the plan first |
| `fix-links` | just created/renamed/removed a doc; fixes the index + links |

---

## 💾 6. Snapshot (automatic versioning)

Before a living doc gets edited, a hook freezes the "before" into `history/`:

```
project_brain/history/<file>/<file> YYYY-MM-DDTHH-mm-ss.md
```

The AI never reads `history/`. It's your safety net for pulling back an old version.

- One snapshot per file every ~20 min (tune it in the script).
- Each file gets a subfolder, so `history/plan_tech/` is its full timeline.
- Covers `.md` under `project_brain/`. The `roadmap/`, `memory/`, and `notes/` folders stay out.

> The hook runs through `run-hook.cmd`, which picks the `.ps1` on Windows and the `.sh` on Mac/Linux. Nothing to install on either.

---

## 🧩 7. Memory

The AI keeps persistent memory as `.md` files with frontmatter. Four types: **user** (who you are, how to collaborate), **feedback** (corrections and confirmed approaches), **project** (decisions, deadlines, context not in the code), **reference** (pointers to external systems).

One memory is one file plus one line in `MEMORY.md` (the index). Save with `/remember`.

> Don't save what the code already holds (patterns, structure, git history). Memory is for what isn't in the code.

### 🔗 Memory inside the vault

By default Claude Code keeps memory outside the repo. setup links it into `project_brain/memory/` with a junction (Windows) or symlink (Mac/Linux), no admin needed. Same files, one place: edit a memory in Obsidian and it's the real one. Your live auto-memory physically moves into the repo at `project_brain/memory/` (the junction relocates the harness's memory there); since `project_brain/` is gitignored it stays local-only and out of the snapshot. (`memory/` stays out of the snapshot, so a deletion there has no `history/` backup.)

Inside `memory/` the format is the harness's: `MEMORY.md` uses `[Title](file.md)`, cross-links use the full file basename `[[type_slug]]` (e.g. `[[feedback_estilo]]`), which is what Obsidian resolves. If the repo moves or gets cloned, run setup again to repoint the link.

---

## 🔒 8. Git

setup appends this block to `.gitignore` (creating it if needed, without clobbering):

```
# === Claude workflow (do not version) ===
.claude/
CLAUDE.md
project_brain/
```

So you push and none of the Claude workflow shows up in the repo. Want to version `memory/` (or `CLAUDE.md`) anyway? Edit the block in the setup script before running.

---

## 🔌 9. Obsidian MCP (recommended)

The MCP gives the AI direct access to your open vault, so it sees and edits notes through the app, not just the filesystem.

1. In Obsidian: **Settings → Community plugins** and install the Claude Code integration plugin (reference repo: `iansinnott/obsidian-claude-code-mcp`). Enable it. (The exact name in community plugins may vary; check the author/description.)
2. Keep **Obsidian open** with this project's vault (the MCP serves over WebSocket, default port `22360`).
3. In Claude Code, inside the project, run `/ide` and pick Obsidian.

- **An MCP server that exposes the vault** (this section): a plugin runs an MCP server inside Obsidian, and Claude Code connects to it.
- **An agent hosted inside Obsidian** (e.g. `yishentu/claudian`, `rait-09/obsidian-agent-client`): Claude runs as a sidebar inside the app. Different setup, skip it for this.

To expose the vault over MCP:

1. In Obsidian: **Settings → Community plugins**, install **Obsidian MCP** (`aaronsb/obsidian-mcp-plugin`, listed as "Semantic Notes Vault MCP"). Enable it.
2. Open its settings tab, generate an **API key**, and note the port (default `3001`).
3. Keep **Obsidian open on this project's vault**. The server runs from inside the app, so a closed Obsidian means the MCP is just gone (the AI falls back to the filesystem, which works fine).
4. In Claude Code, from the project root, register it once:
   ```
   claude mcp add --transport http obsidian http://localhost:3001/mcp --header "Authorization: Bearer <your-api-key>"
   ```

It persists across sessions: register once, and from then on it connects whenever Obsidian is open on the vault. One vault per blueprint.

---

## 🗺️ 10. Day to day

Starting a session (or `/start`), the AI follows the cheat sheet in `CLAUDE.md`: reads `CLAUDE.md`, then `next_step.md`, and pulls `plan_tech`, `map_index`, `Vision`, or `MEMORY` as needed.

Through the work, the truth stays aligned, mostly via skills:
- Finished a task → `/done`.
- About to change architecture → `check-plan` fires; if the plan changed, update the roadmap.
- Created/renamed/removed a doc → `fix-links` fixes the indexes.
- Wrapping up → `/end` runs the whole ritual.

You only write in `Vision.md` and `notes/` when you feel like it. The AI keeps the rest.
