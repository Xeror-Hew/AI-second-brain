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

1. Run the OS setup script. Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File .claude\setup.ps1`. Mac/Linux: `bash .claude/setup.sh`. (Memory junction/symlink plus the `.gitignore` block.)
2. Fill the `{{PLACEHOLDERS}}` in `CLAUDE.md` and `project_brain/context.md`. Ask the user for what you can't infer.
3. **Language**: see §4.
4. Ask for the user's vision in `project_brain/Vision.md`, or help write it.
5. If there's code, run `/map`. With the vision, run `/writeplan`, then derive the `roadmap`.
6. Set `project_brain/next_step.md` to one item.
7. Remind them about the superpowers plugin (one click when they trust the folder). See [[README]].
8. **MCP**: see §5.
9. **Existing notes or an old workflow?** If the project already has plans, notes, or its own workflow folder, leave it where it is. Offer to read it and fold the useful parts into the structure (Vision, plan, roadmap, memory), using judgment and confirming as you go. Adapt the content, do not force a rigid mapping, and never move or delete the user's own files without asking.

## 3. Upgrade (same blueprint, newer version)

The project already runs this blueprint and the dropped folder is the new version. Refresh the engine, keep the user's content.

1. **Check versions.** Read `.claude/.blueprint-version` in the dropped folder and at the root. No file at the root means a pre-versioning install: treat it as older. Dropped version not newer: tell the user they are already up to date and stop. Dropped version older: say it is a downgrade and confirm before going on.
2. **Refresh the engine.** Replace the root `.claude/` with the dropped one: hooks, skills, setup scripts, `settings.json`, and the version marker. Pure template, safe to overwrite.
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

English: skip the rest of this step. Any other choice: localize the install.

**Translate** (what the human reads/edits): the docs in `project_brain/`, `CLAUDE.md`, each skill's `description` and `when_to_use` triggers. `README` is optional.

**Keep in English** (structure and engine): folder and file names, wikilink targets (`[[project_brain/...]]`), code (`.ps1/.sh/.cmd`), `settings.json`, `{{PLACEHOLDERS}}`, tool names, and skill bodies (the AI reads English fine, and they live in hidden `.claude/`).

The rule: translate human text, keep identifiers, paths, and code as they are. That keeps every link and the hooks working.

## 5. MCP (final step, conversational)

Setup ran and language is handled. Now walk the user through the Obsidian MCP in conversation. The MCP gives the AI direct access to the open vault, seeing and editing notes through the app on top of the filesystem. Ask which external tools or services they want Claude connected to, point them at the config, and reference the README's MCP section ([[README]] §9) for the install steps (community plugin, Obsidian open on this vault, `/ide` to connect). It's a bonus: closed app, the AI falls back to the filesystem.

## Always, at the end

Recap what got set up and the `next_step`. If a step needs the user (run a script, accept the plugin prompt, open Obsidian), spell it out.
