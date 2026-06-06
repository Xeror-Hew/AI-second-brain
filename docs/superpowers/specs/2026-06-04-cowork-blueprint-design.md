# Cowork Blueprint — design (SUPERSEDED)

> ⚠️ **Superseded 2026-06-05.** This 2026-06-04 spec was written on a wrong framing: "Cowork" as a git-removed **knowledge-worker fork running on the Claude Code CLI**, with `code_map → library`.

The actual design: **"Cowork" = Claude Cowork, the desktop agentic surface.** The blueprint runs from one folder across THREE surfaces (Claude Code / Claudian / Claude Cowork) with office vocabulary. It keeps `work_map/` (territory) AND `library/` (deliverables) distinct, versions via a surface-aware snapshot with no runtime env var (hook on Code/Claudian + brain-MCP-routed snapshot wherever it loads + `/snapshot` fallback), and adds `/triage` plus clean-room office skills `/make-deck /make-sheet /make-doc`.

Current record of the real design: the realigned `Claude Cowork Blueprint/` itself, and the session memory `project_cowork-blueprint`.

What survived from this spec: `/draft` + `/research`, `debloat` → `tidy`, dropping `/tdd` + `/worktree` + the guard-commit hook, the lay-user framing, and the roadmap log without the git hash. What changed: it is multi-surface (not a Claude Code fork), the descriptive structure is `work_map` (not `library`-renamed-from-`code_map`), git stays optional rather than removed, and the snapshot is surface-aware rather than hook-only.
