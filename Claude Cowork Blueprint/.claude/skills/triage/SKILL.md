---
name: triage
description: Sort, rename, deduplicate, and surface what matters in a pile of incoming or scattered material, without losing anything.
when_to_use: user says "organize these files", "sort this out", "clean up this folder", "find what matters", "deduplicate", "sort my downloads"; or you're handed a folder of unsorted material before producing.
---

# Triage

Turn a pile of incoming or scattered material (drafts, downloads, attachments, loose notes) into something ordered, without losing anything. This works on the **user's own material**. `/tidy` is the equivalent for the brain's own docs; `/work-map` maps the workspace once it's in order.

## The one rule

```
NOTHING IS LOST: propose before you move, never delete what's theirs
```

You reorganize; you don't discard. Stale or superseded material gets archived, not deleted. Any real deletion is the user's call.

## The loop

1. **Survey.** List the target folder and read enough of each item to know what it is: type, topic, which are duplicates or near-duplicates, which look current vs stale, which matter to the work at hand. Change nothing yet. If it touches a part of the workspace you already know, check `work_map` first.
2. **Propose a plan.** Show the user before acting: the groupings (where things go), the renames (clearer names), the duplicates (which to keep, which to fold in), what looks stale (to archive), and what's most relevant to what they're doing now. One pass, concrete.
3. **Confirm.** It's their material. Get a yes on the plan (or adjust it) before touching anything.
4. **Execute, non-destructively.** Move, don't delete: group into folders, rename for clarity, keep one of each duplicate. Stale or superseded items go to an archive (an `_archive/` folder, or `project_brain/history/` if they're brain docs), never to the trash. Editing a brain doc in the process? It snapshots on a routed write; on a hand edit with no hook, `/snapshot` first. Anything that genuinely should be deleted: list it and let the user delete it.
5. **Record.** Note what changed with `/done` (one line in the log), and update `work_map` so the new shape of the workspace is mapped.

## Before "done"

- Is everything accounted for (nothing deleted, nothing orphaned)?
- Did the user confirm the plan before you moved things?
- Is the new layout reflected in `work_map`?
