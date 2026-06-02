# Project context · {{PROJECT_NAME}}

> Project-specific config. Fill it in at setup. Indexed from `CLAUDE.md` ("Project context").

---

## 🧰 Stack / environment

{{STACK}}
<!-- e.g. Python 3.14 global, no venv · Windows · Postgres 16 -->

---

## 🎯 Principles (priority order when things conflict)

{{PRINCIPLES}}
<!-- e.g.
1. 🎯 Accuracy
2. 💰 Low cost
3. 🧹 Simple (wins ties)
4. ⚡ Speed
-->

---

## 📏 Specific rules

{{SPECIFIC_RULES}}
<!-- rules unique to this project, e.g. limited budget, never run the real process -->

---

## 🔒 Commit policy

- **No AI attribution, ever** (fixed for every project): no `Co-Authored-By`, no "Generated with" footer. Setup enforces it with a `commit-msg` hook plus `settings.json`. See `CLAUDE.md` rule 8.
- {{e.g. autonomous commits when it makes logical sense; split into logical commits}}
