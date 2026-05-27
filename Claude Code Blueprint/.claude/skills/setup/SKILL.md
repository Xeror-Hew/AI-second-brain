---
name: setup
description: Install this blueprint into a project, fresh or as an upgrade. Wires it up, fills placeholders, localizes, and can fold existing notes into the structure when asked.
when_to_use: when dropping this blueprint into a project (new or existing), or updating it to a newer version; user says "setup", "install the blueprint", "set this up", "onboard", "update the blueprint"
---

You just got dropped into a project with this blueprint. Orchestrate the install. **Preserve the user's content**: never rename or delete their folders, and confirm before moving anything that is theirs.

## 0. Where the blueprint files are

The only pieces you install are `CLAUDE.md`, `.claude/`, and `project_brain/`. They may be:
- **Already at the root**: go straight ahead.
- **Inside the folder the user dropped** (e.g. `Claude Code Blueprint/`): that's the source. Move just those three to the root. The folder's own `README.md` and `README.pt-BR.md` are install docs, not part of the project: leave them in the dropped folder and delete the whole folder at the end. Never copy a `README` over one the user already has. Then tell the user to reopen the session so the skills load from the root.

## 1. Which case is this?

- **Not installed yet** (a fresh project, or an existing one with its own files): install fresh, §2. Anything already in the project that is not part of the blueprint stays exactly where it is.
- **Already installed** (the root has a `.claude/.blueprint-version` or a `project_brain/`) and the dropped folder is a newer copy: upgrade, §3.

## 2. Install (fresh)

1. Run the OS setup script. Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File .claude\setup.ps1`. Mac/Linux: `bash .claude/setup.sh`. (Memory junction/symlink plus the `.gitignore` block.) The auto-mode permission classifier often denies this call (the `-ExecutionPolicy Bypass` on a freshly-dropped script reads as running an unreviewed script). If it's blocked, either ask the user to run the line themselves with a `!` prefix in the prompt, or do the script's two operations yourself: append the Claude block to `.gitignore`, and create the memory junction (`mklink /J <harness-memory-path> <project_brain/memory>` on Windows, the symlink equivalent on Mac/Linux).
2. Fill the `{{PLACEHOLDERS}}` in `CLAUDE.md` and `project_brain/context.md`. Ask the user for what you can't infer.
3. **Language**: see §4.
4. Ask for the user's vision in `project_brain/Vision.md`, or help write it.
5. If there's code, run `/map`. With the vision, run `/writeplan`, then derive the `roadmap`.
6. Set `project_brain/next_step.md` to one item.
7. Remind them about the superpowers plugin: `.claude/settings.json` already declares it, so when they trust the project folder Claude Code offers to install the marketplace plus plugin in one click. No prompt? `claude plugin install superpowers@claude-plugins-official`.
8. **MCP**: see §5.
9. **Existing notes or an old workflow?** If the project already has plans, notes, or its own workflow folder, leave it where it is. Offer to read it and fold the useful parts into the structure (Vision, plan, roadmap, memory), using judgment and confirming as you go. Adapt the content, do not force a rigid mapping, and never move or delete the user's own files without asking. If the project already carries accumulated auto-memory, it probably duplicates the docs you just created (roadmap, plan, code map, environment), and stale memory diverges from the live docs over time. Offer to reconcile it now with `/debloat`, which handles a memory pass.

## 3. Upgrade (same blueprint, newer version)

The project already runs this blueprint and the dropped folder is the new version. Refresh the engine, keep the user's content.

1. **Check versions.** Read `.claude/.blueprint-version` in the dropped folder and at the root. No file at the root means a pre-versioning install: treat it as older. Dropped version not newer: tell the user they are already up to date and stop. Dropped version older: say it is a downgrade and confirm before going on.
2. **Refresh the engine.** Replace the root `.claude/` with the dropped one: hooks, skills, setup scripts, `settings.json`, and the version marker. Pure template, safe to overwrite. The auto-mode classifier may prompt the user to approve edits to `.claude/skills/**` and `CLAUDE.md`, since it treats them as agent-startup-config self-modification. This is expected; the user approves on the spot or adds a permission rule.
3. **Merge `CLAUDE.md`.** The new one is the base; carry over the user's filled placeholders and any custom rules from the root one.
4. **Leave the content alone.** Do not touch the root `project_brain/` or `memory/`. The dropped folder's `project_brain/` is an empty template, never copy it over the user's.
5. **If the install was localized** (the root content is not in English), re-run §4 on the new engine so the refreshed skills and `CLAUDE.md` speak the user's language again.
6. Run the OS setup script (idempotent: fixes the junction and gitignore if needed).
7. Run `/fix-links` if any doc moved or got renamed in this version.
8. Delete the dropped folder. Tell the user to reopen the session so the new skills load.

## 4. Language (localization)

First, infer the user's language from how they have been writing in this conversation. Phrase the whole `AskUserQuestion` (question, labels, descriptions) in that language, so someone who reads no English still understands the prompt. Fall back to English only when the language is genuinely unclear.

The blueprint ships in English. Present the choice with one `AskUserQuestion` call, a single question about install language, with these three options (written in the inferred language):

- **Keep it in English** the original canonical language, no translation.
- **Translate to <inferred language>** everything human-facing into the language inferred from the conversation. Name it in the label, e.g. "Portuguese (Brazilian)".
- **Choose another language** the user names which, then translate into that.

English: skip the rest of this step. Any other choice: localize the install. Localizing translates the human text **and** the folder, file, and skill (command) names, then rewrites every reference so nothing breaks. Do this carefully; a missed reference breaks a link or silently kills the snapshot hook.

**Translate the prose** (what the human reads/edits): the docs in `project_brain/`, `CLAUDE.md`, the README, each skill's `description` and `when_to_use` triggers.

**Translate the names** (rename, then rewrite all references):
- `project_brain/` and its subfolders `plan/`, `roadmap/`, `code_map/`, `history/`, `notes/`.
- The doc files: `Vision.md`, `context.md`, `next_step.md`, the `plan_*.md`, `roadmap*.md`, `map_index.md`, `notes_index.md`.
- The skill folders under `.claude/skills/`. The folder name **is** the slash command, so renaming `start/` to the localized verb renames `/start`.

**Stays English** (renaming these breaks the engine or the Claude Code contract):
- `.claude/` and `CLAUDE.md`: Claude Code requires these exact names at the root.
- `settings.json` and its keys.
- The hook script files and extensions: `run-hook.cmd`, `snapshot.ps1`/`snapshot.sh`, `remind-map.ps1`/`remind-map.sh`.
- `.blueprint-version`, the `{{PLACEHOLDERS}}`, tool names.
- The whole `memory/` subtree: the folder `memory/`, `MEMORY.md`, and the `_TEMPLATE_*.md` files. The harness auto-memory owns that folder and writes those exact names itself; translating them desyncs from the harness.

**What renaming forces you to rewrite** (go through all of these):
- Every wikilink and path reference across `CLAUDE.md`, the docs, and the indexes becomes the translated path.
- Skill cross-references: command tokens like `/done`, `/map`, `/fix-links`, `/writeplan` in `CLAUDE.md`, the README, and inside skill bodies become the localized commands (the folder name is the command). The surrounding skill-body prose stays English; only the command tokens change.
- The hooks hardcode folder names as literal strings. `snapshot.ps1` and `snapshot.sh` test for the `project_brain` marker and exclude `history`, `memory`, `roadmap`, `notes` by literal name; `setup.ps1`/`setup.sh` hardcode the `project_brain/memory` junction target and list `project_brain/` in the `.gitignore` block. If you rename `project_brain` or a snapshotted subfolder, patch those literals in all four scripts, or the snapshot hook silently stops firing (the hooks always exit 0, so a wrong path fails invisibly).

**Verify after localizing:** edit any living doc and confirm a snapshot lands under the (translated) `history/` folder. This is the existing "check the hook" step, reused to catch a broken snapshot path. Then grep the docs and skills for stray old command tokens left from the rename.

The one real downside: localized commands and paths diverge from the README and any community references, which all use the English names.

## 5. MCP (final step, conversational)

Setup ran and language is handled. Now walk the user through the Obsidian MCP in conversation. The MCP lets the AI read and edit the open vault through Obsidian on top of the filesystem. Ask which external tools or services they want Claude connected to and point them at the config.

Two different things share the "Obsidian + Claude" name; keep them apart:
- **(a) An MCP server that exposes the vault** (what we want): a plugin runs an MCP server inside Obsidian, and Claude Code connects to it.
- **(b) An agent hosted inside Obsidian** (e.g. `yishentu/claudian`, `rait-09/obsidian-agent-client`): Claude as a sidebar in the app. A different setup, skipped here.

For (a):
1. Install the community plugin **Obsidian MCP** (`aaronsb/obsidian-mcp-plugin`, listed in the catalog as "Semantic Notes Vault MCP") and enable it.
2. In its settings tab, generate an API key. Default port is `3001`.
3. Keep Obsidian open on this project's vault. The server runs inside the app, so a closed Obsidian means the MCP is simply absent and the AI falls back to the filesystem, which works fine.
4. Register once from the project root: `claude mcp add --transport http obsidian http://localhost:3001/mcp --header "Authorization: Bearer <key>"`. It persists across sessions. Do not use `/ide`.

## Always, at the end

Recap what got set up and the `next_step`. If a step needs the user (run a script, accept the plugin prompt, open Obsidian), spell it out.
