---
name: snapshot
description: Manually freeze the brain's living docs into history/ when no automatic snapshot is in play (e.g. Claude Cowork, which has no hooks).
when_to_use: before you change a brain doc on a surface without the snapshot hook (Claude Cowork), or any time you want a safety copy on the spot; user says "snapshot", "save a version", "back up the brain"
---

# Snapshot

On Claude Code and Claudian the snapshot hook versions your docs automatically before each edit. Claude Cowork has no hooks, so when you edit a brain doc by hand there, freeze a copy yourself first.

Run:

```bash
node .claude/hooks/snapshot-all.mjs
```

It copies every living doc in `project_brain/` into `project_brain/history/<file>/<file> <timestamp>.md`, skipping `roadmap/` (it keeps its own log) and `notes/` (your scratch space), and skipping anything already snapshotted in the last 20 minutes. Same naming and cooldown the hook and the brain MCP use, so all three share one history.

**Prefer the brain MCP for brain-doc edits** (`brain_append`, `brain_set_next`, `brain_log_done`): wherever it's loaded, it snapshots before it writes, so routed edits are covered without a hook. Reach for `/snapshot` when you edit a brain doc by hand and nothing automatic is there to catch it: a hand edit on Code/Claudian, or any Cowork edit the MCP didn't make.
