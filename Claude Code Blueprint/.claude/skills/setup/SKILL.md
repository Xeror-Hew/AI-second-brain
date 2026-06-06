---
name: setup
description: Install this blueprint into a project, fresh or as an upgrade. Maps the code, builds the brain, folds in existing notes, merges CLAUDE.md, localizes, and reconciles your customizations on update.
when_to_use: when dropping this blueprint into a project (new or existing), or updating it to a newer version; user says "setup", "install the blueprint", "set this up", "onboard", "update the blueprint"
---

You just got dropped into a project with this blueprint. Orchestrate the install. **Preserve the user's content**: never rename or delete what is theirs, and confirm before moving anything you did not create.

> **How you got here.** On a first install the `/setup` skill is not registered yet: it sits inside the dropped subfolder, and Claude Code only registers a subfolder's skills after the files reach the project root. So the user installs by pointing you at the dropped folder ("read and follow `Claude Blueprint`"), and you find and read this file directly. That is expected, and it is deliberately "read and follow <folder>", not "install the blueprint": a vague install phrase can be grabbed by another installed skill (e.g. a skill-registry search) instead. Run §0 to get the files to the root; from then on the slash commands exist.

## 0. Place the files

The installed footprint is `CLAUDE.md`, `.claude/`, `project_brain/`, and `.mcp.json` at the project root. They may be:
- **Already at the root**: go ahead.
- **Inside the folder the user dropped** (e.g. `Claude Code Blueprint/`): that is the source. Move those four to the root. `README.md` and `README.pt-BR.md` are install docs, not part of the project; leave them in the dropped folder and delete the whole folder at the end. Never copy a README over one the user already has.

**Merge, never overwrite, when the root already has a file.** This blueprint installs into existing projects, so assume the user already has work at the root and protect it:
- **`CLAUDE.md`**: if the root has one, it is the user's and it stays. Do not replace it. Keep all of their content, then fold the blueprint's sections in around it (the intro callouts, `Workflow rules`, `Doc rules`, `Skills / commands`, `Engine`, `Project context`, `Navigation`), and fill the `{{PLACEHOLDERS}}` from what you learn (ask for what you cannot infer). Their project-specific rules win on any conflict; move purely project-specific config into `project_brain/context.md`. If the root has no `CLAUDE.md`, the blueprint's becomes it.
- **`.claude/settings.json`**: merge keys. Keep the project's `permissions`/`env`/custom hooks, add the blueprint's `hooks`, `includeCoAuthoredBy: false`, the empty `attribution`, and the `enabledPlugins` entry that turns the external `superpowers` plugin off for this project (the engine is forked in, so the plugin would only duplicate skills and double the session injection; it stays on in the user's other projects). The no-AI-attribution policy is fixed: keep it on even if the project had it off.
- **`.claude/` subtrees** (`skills/`, `hooks/`, `mcp/`, `agents/`): additive. Drop the blueprint's in alongside whatever is there (an empty `.claude/skills/` from another tool is fine; nothing of the user's gets removed).
- **`project_brain/`**: if the root already has one, this is an upgrade, go to §3. The dropped `project_brain/` is an empty template, never copy it over content.

Two more items ship in the dropped folder; bring them along with the same merge-never-overwrite rule. **`.obsidian/`** is a vault config tuned for the brain: move it to the root only if the root has none; if the project is already an Obsidian vault, keep the user's `.obsidian/` and leave it. It is optional, the brain works as plain markdown without it. **`.gitattributes`**: if the root has one, append the blueprint's lines to it, otherwise move it.

Then have the user run `/reload-skills` (Claude Code 2.1.152+) or reopen the session so the bare `/verbs` load.

## 1. Which case?

- **Fresh** (no root `project_brain/` and no `.claude/.blueprint-version`): §2. Anything in the project that is not part of the blueprint stays exactly where it is.
- **Upgrade** (the root has them and the dropped folder is newer): §3.

## 2. Install (fresh)

The flow builds the brain on top of the real project, in order:

1. **Wire the OS.** Run the setup script: Windows `powershell -NoProfile -ExecutionPolicy Bypass -File .claude\setup.ps1`, Mac/Linux `bash .claude/setup.sh`. It creates the memory junction/symlink, the `.gitignore` block, and the no-AI-attribution `commit-msg` hook. If the auto-mode classifier blocks the `-ExecutionPolicy Bypass` call (a freshly dropped script reads as unreviewed), ask the user to run the line with a `!` prefix, or do the operations yourself: append the gitignore block, create the memory junction (`mklink /J` on Windows, the symlink on Mac/Linux), and install the `commit-msg` hook (resolve the hooks dir: `.husky/` if present, else `git config core.hooksPath`, else `git rev-parse --git-path hooks`; copy the body and marker-based idempotency/backup logic, `chmod +x`).
2. **Map the code.** If the project has code, run `/map` first. The brain gets built on what the map reveals.
3. **Build the brain on the map.** Fill the `{{PLACEHOLDERS}}` in `CLAUDE.md` and `project_brain/context.md` (ask for what you cannot infer). Ask for the user's vision in `project_brain/Vision.md`, or draft it from the code and the map for them to confirm. Run `/writeplan`, derive the `roadmap`, set `next_step.md` to one item.
4. **Absorb scattered notes.** If the project already carries plans, notes, or its own workflow folder, leave the originals where they are and offer to fold the useful parts into the structure (Vision, plan, roadmap, memory). Adapt the content, do not force a rigid mapping, confirm as you go. Move clearly-stale ideas into `project_brain/history/` rather than deleting them.
5. **Reconcile memory.** If the project carries accumulated auto-memory, it probably duplicates the docs you just built (roadmap, plan, map) and drifts from them over time. Offer to reconcile it now with `/debloat` (it runs a memory pass).
6. **Language**: §4.
7. **MCP**: §5.
8. **Report.** Recap what you did, mapped, built, absorbed, reconciled, plus the `next_step`.

## 3. Upgrade (newer version, keep the user's work)

Refresh the engine and reconcile the customizations. Never wipe what the user changed.

1. **Check versions.** Compare `.claude/.blueprint-version` in the dropped folder against the root. No root file means a pre-versioning install, treat it as older. Dropped not newer: tell them they are up to date and stop. Dropped older: say it is a downgrade and confirm first.
2. **Reconcile the engine, do not blind-overwrite.** The engine (`.claude/skills`, `hooks`, `mcp`, `agents`, setup scripts, version marker) is template, but the user may have customized it. For each engine file: if the root copy matches the old version, replace it with the new one; if the user changed it, reason about the merge, bring in the new version's improvements, and keep their change, asking when a conflict is genuinely unclear. `settings.json`: merge (keep their `permissions`/`env`/custom hooks; bring in the blueprint's `hooks`/`includeCoAuthoredBy`/`attribution`/`enabledPlugins`).
3. **Merge `CLAUDE.md`.** The new one is the base; carry over the user's filled placeholders and any custom rules.
4. **Leave the content alone.** Do not touch the root `project_brain/` docs or `memory/`. The dropped `project_brain/` is an empty template, never copy it over theirs. Bring in a genuinely new template file (a new doc type this version adds) without overwriting an existing one.
5. **Localized install?** If the root content is not in English, re-localize the refreshed engine (skill folder names, `CLAUDE.md` prose, each skill's `description`/`when_to_use`) into the user's language, and reconcile the manifest per §4 "Localized upgrades". The user's existing localized folders and `.brain.json` stay untouched; you only translate what this version newly added.
6. Run the OS setup script (idempotent: fixes the junction and gitignore if needed). Run `/fix-links` if a doc moved or got renamed this version.
7. Delete the dropped folder. Have the user run `/reload-skills` or reopen the session.

## 4. Language (localization)

Infer the user's language from how they write in this conversation. Phrase the whole `AskUserQuestion` (question, labels, descriptions) in that language, so someone who reads no English still understands it. The blueprint ships in English; present one question with three options (written in the inferred language): keep English · translate to <inferred language> · choose another.

English: skip the rest. Any other choice localizes both the prose and the names.

**Translate the prose** (what the human reads): the docs in `project_brain/`, `CLAUDE.md`, each skill's `description` and `when_to_use`.

**Localize the names through the manifest** `project_brain/.brain.json`. For each canonical key under `names`, set the value to the translated folder/file name (`plan`→`plano`, `roadmap`→`roteiro`, `next_step`→`proximo_passo`, `code_map`→`mapa`, `notes`→`notas`, `Vision`→`Visao`, `context`→`contexto`); under `sections`, translate the two roadmap headings (`BLOCKERS`, `CURRENT FRONT`). Then rename the physical folders and files on disk to match the values, including the files inside them (`roteiro/roteiro.md`, `roteiro/roteiro_log.md`, the `plano_*.md`, and so on). The brain MCP and the snapshot hook read the manifest, so resolution follows automatically; you patch no engine script. `project_brain`, `history`, and `memory` stay canonical, do not rename them or list them in the manifest.

**Localize the commands**: rename the skill folders under `.claude/skills/` (the folder name is the slash command), then rewrite every `/verb` token in `CLAUDE.md`, the docs, and inside skill bodies to the localized command. The skill-body prose stays English; only the command tokens change.

**Stays English** (renaming breaks the engine or the Claude Code contract): `.claude/`, `CLAUDE.md`, `settings.json` and its keys, the hook script filenames, `.mcp.json`, `.blueprint-version`, the `{{PLACEHOLDERS}}`, MCP tool names, and the whole `memory/` subtree (harness-owned).

**Rewrite the references**: every wikilink and path in `CLAUDE.md` and the docs becomes the translated path.

**Verify after localizing**: edit a living doc and confirm a snapshot lands under `history/`; call `brain_orient` and confirm it still finds the next step and roadmap; grep the docs and skills for stray old command tokens.

### Localized upgrades (what keeps a future version from breaking a localized install)

The localized names live as data in `project_brain/.brain.json`, and the engine (brain MCP plus the snapshot hook) resolves every path through it. No localized path is ever baked into engine code, so refreshing the engine on an upgrade cannot break a localized install. When upgrading one (§3 step 5):

1. **Keep the user's `.brain.json` and their renamed folders/files untouched.** Existing localized content keeps resolving through the preserved manifest.
2. **Reconcile only what is new.** Diff the new version's shipped default `.brain.json` (the canonical key-set for this version) against the user's. For each canonical key this version adds and the user lacks: translate its value into the user's language, add the key to the user's `.brain.json`, and create the matching localized folder or file. Translate any new `sections` heading the new version reads.
3. **Never re-translate or rename an existing key.** Touch only the additions, then run the verify step above.

## 5. MCP (final step, conversational)

The brain MCP is already registered via `.mcp.json` (it needs `node` on PATH; without it the brain still works on the filesystem). Now offer the optional Obsidian live layer. Two things share the "Obsidian + Claude" name; keep them apart:
- **(a) An MCP server that exposes the vault** (what we want): a community plugin runs an MCP server inside Obsidian, and Claude Code connects to it.
- **(b) An agent hosted inside Obsidian**: a different setup, skipped here.

For (a): install the **Obsidian MCP** community plugin (`aaronsb/obsidian-mcp-plugin`, listed as "Semantic Notes Vault MCP") and enable it; generate an API key in its settings tab (default port `3001`); keep Obsidian open on this vault; register once from the project root: `claude mcp add --transport http obsidian http://localhost:3001/mcp --header "Authorization: Bearer <key>"`. It persists across sessions. A closed Obsidian just means the MCP is absent and the AI falls back to the filesystem.

## Always, at the end

Recap what got set up and the `next_step`. If a step needs the user (run a script, accept a prompt, open Obsidian), spell it out.
