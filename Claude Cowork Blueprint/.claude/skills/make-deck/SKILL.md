---
name: make-deck
description: Produce a polished PowerPoint (.pptx) slide deck from a brief or outline, in house style, without wall-of-text slides.
when_to_use: user says "make a deck", "build the slides", "put this in PowerPoint", "create a presentation"; or a task calls for a slide deck as the deliverable.
---

# Make deck

Produce a real `.pptx` deck that looks designed, not generated. The story comes first; the file is the last step.

## Library

Generate with **python-pptx** (MIT) — it writes native `.pptx`, no LibreOffice needed. No Python available? Hand back a clean slide-by-slide outline in markdown and say a deck file needs Python (point to python.org). On Cowork, defer the file mechanics to the built-in deck capability and use these rules to shape it.

## House style

Read `project_brain/context.md` ("Office house style") for palette, fonts, logo, and template. None set? Pick one restrained scheme and note it so it can be saved.

## The loop

1. **Story first.** Settle the one message and the arc before any slide: who's the audience, what they should think or do, the 5-12 beats that get there. Run `/check-library` so you build on existing decks and material. For the prose on content-heavy slides, `/draft` the text first.
2. **One idea per slide.** Each slide carries a single point. The title states the takeaway, not a label. The body is few words, not paragraphs.
3. **Generate.** Write a python-pptx script and run it: house palette and fonts, a consistent layout, speaker notes for the detail that doesn't belong on the slide. Save to the right place in the vault.
4. **Verify.** Open/inspect the file. If LibreOffice is present, render slides to images and eyeball the layout (nothing clipped, contrast readable); if not, skip with a note. Fix what's off.
5. **Finish.** `/critique` before you call it done, then `/done`.

## Anti-slop rules

- Takeaway titles, not topic labels ("Revenue up 40% on enterprise" beats "Revenue").
- Max ~5 bullets a slide; if it needs more, it's two slides.
- No paragraph dumped on a slide; the detail goes in speaker notes.
- Consistent palette and fonts throughout; no stock-clipart filler.
- Every number on a slide has a source in the notes.

## Before "done"

- One clear message per slide, takeaway titles?
- House style applied consistently?
- Nothing clipped or unreadable (checked, not assumed)?
