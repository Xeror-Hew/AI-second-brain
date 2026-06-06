# Credits

This blueprint's engine skills (`/diagnose`, `/critique`, `/execute`, `/writeskill`, `/brainstorm`, `/writeplan`) are forked from **superpowers** by Jesse Vincent (obra), MIT-licensed:
https://github.com/obra/superpowers

They were vendored into the blueprint and adapted to it: trimmed, renamed to bare verbs, retargeted from code to knowledge work, fused with the brain skills, and pointed so their output lands in `project_brain/`. `/draft`, `/research`, `/triage`, `/work-map`, and the brain-core skills are the blueprint's own, built in the same evidence-first spirit. Owning the fork lets the integration travel with the blueprint and survive updates; upstream changes get reconciled by hand each release, and improvements go back upstream.

`/make-deck`, `/make-sheet`, and `/make-doc` are the blueprint's own, built over permissively-licensed libraries (python-pptx, openpyxl, pandas, python-docx; MIT/BSD), with LibreOffice (MPL-2.0) invoked optionally as an external tool. They were written clean-room: Anthropic's published office skills (source-available, all-rights-reserved) were studied as a reference but never copied, and nothing from them is vendored here.

The skill-authoring discipline (trigger-only descriptions, tight word counts), the "evidence before claims" verification gate, and the anti-flattery stance on review all come from superpowers' guidance.

superpowers is © Jesse Vincent, released under the MIT License. This blueprint is © Hewstore, also MIT (see LICENSE).
