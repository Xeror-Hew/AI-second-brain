---
name: setup
description: Install/migrate this blueprint into a project: wires it up, fills placeholders, localizes, and migrates an old workflow if there is one.
when_to_use: when dropping this blueprint into a project (new or existing); user says "setup", "install the blueprint", "set this up", "onboard", "migrate workflow"
---

You just got dropped into a project with this blueprint. Orchestrate the install. **Preserve the user's content**: in a migration, move or merge, and confirm before moving or deleting anything.

## 0. Where the blueprint files are

`CLAUDE.md`, `.claude/`, and `project_brain/` may be:
- **Already at the root** (clean root): go straight ahead.
- **Inside the blueprint folder the user dropped** (e.g. `Claude Code Blueprint/`) or another staging folder: that's the source. Reconcile with whatever is at the root (steps below), move the final files to the root, and delete the staging folder at the end. Tell the user to reopen the session so the skills load from the root.

Merge into an existing `CLAUDE.md`: the new one is the base, the user's filled-in values (placeholders, rules) carry over.

## 1. Detect the scenario

- A `desenvolvimento/` folder or a `Plano CLAUDE.md` file: an **old version of this blueprint**. Go to **2b**.
- Another `CLAUDE.md` and/or a workflow-docs folder from a different model: a **foreign workflow**. Go to **2c**.
- None of that: a **clean** project. Go to **2a**.

## 2a. Fresh setup (clean project)

1. Run the OS setup script. Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File .claude\setup.ps1`. Mac/Linux: `bash .claude/setup.sh`. (Memory junction/symlink plus the `.gitignore` block.)
2. Ask the user for the `{{PLACEHOLDERS}}` (in `CLAUDE.md` and `project_brain/context.md`) and fill them.
3. **Language**: see §3.
4. Ask for the user's vision in `project_brain/Vision.md` (or help write it).
5. If there's code, run `/map`; with the vision, run `/writeplan`; derive the `roadmap`.
6. Set `project_brain/next_step.md` to one item.
7. Remind them: the superpowers plugin (one click when they trust the folder). See [[README]].
8. **MCP**: see §4.

## 2b. Migration: old version of this blueprint (`desenvolvimento/`)

1. **CLAUDE.md**: take the new one (current rules and skills) but carry over what the user filled in the old one (placeholders, custom rules).
2. Rename `desenvolvimento/` to `project_brain/`.
3. Rewrite the `desenvolvimento/` wikilinks to `project_brain/` across all `.md`.
4. If there's a `Plano CLAUDE.md`, split it into `project_brain/plan/` (`plan_index`, `plan_summary`, `plan_why`, `plan_tech`) and fix the links that pointed at it.
5. Make sure the hooks scope on `project_brain` (`.claude/hooks/snapshot.*`).
6. Run the OS setup script (recreates or repoints the junction/symlink, plus gitignore).
7. Run `/fix-links` to sweep dead and orphan links.
8. **Language**: see §3.
9. **MCP**: see §4.

## 2c. Migration: foreign workflow (preserve and merge)

1. **Before touching anything**, list the existing workflow docs and say what each is.
2. Propose a mapping to the new layout:
   - vision/goal → `project_brain/Vision.md`
   - technical plan → `project_brain/plan/`
   - tasks/TODO → `project_brain/roadmap/`
   - code state → `project_brain/code_map/`
   - decisions/persistent context → `project_brain/memory/`
3. With approval, move the content over (preserved), fill the placeholders, run the OS setup script.
4. Decide with the user what to do with the old `CLAUDE.md`: merge the useful rules into the new one, or archive it.
5. **Language**: see §3.
6. **MCP**: see §4.

## 3. Language (localization)

First, infer the user's language from how they have been writing in this conversation. Phrase the whole `AskUserQuestion` (question, labels, descriptions) in that language, so someone who reads no English still understands the prompt. Fall back to English only when the language is genuinely unclear.

The blueprint ships in English. Present the choice with one `AskUserQuestion` call, a single question about install language, with these three options (written in the inferred language):

- **Keep it in English** the original canonical language, no translation.
- **Translate to <inferred language>** everything human-facing into the language inferred from the conversation. Name it in the label, e.g. "Portuguese (Brazilian)".
- **Choose another language** the user names which, then translate into that.

English: skip the rest of this step. Any other choice: localize the install.

**Translate** (what the human reads/edits): the docs in `project_brain/`, `CLAUDE.md`, each skill's `description` and `when_to_use` triggers. `README` is optional.

**Keep in English** (structure and engine): folder and file names, wikilink targets (`[[project_brain/...]]`), code (`.ps1/.sh/.cmd`), `settings.json`, `{{PLACEHOLDERS}}`, tool names, and skill bodies (the AI reads English fine, and they live in hidden `.claude/`).

The rule: translate human text, keep identifiers, paths, and code as they are. That keeps every link and the hooks working.

## 4. MCP (final step, conversational)

Setup ran and language is handled. Now walk the user through the Obsidian MCP in conversation. The MCP gives the AI direct access to the open vault, seeing and editing notes through the app on top of the filesystem. Ask which external tools or services they want Claude connected to, point them at the config, and reference the README's MCP section ([[README]] §9) for the install steps (community plugin, Obsidian open on this vault, `/ide` to connect). It's a bonus: closed app, the AI falls back to the filesystem.

## Always, at the end

Recap what got set up and the `next_step`. If a step needs the user (run a script, accept the plugin prompt, open Obsidian), spell it out.
