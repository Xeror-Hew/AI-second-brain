---
name: make-doc
description: Produce a formatted Word (.docx) document with real styles, from finished prose.
when_to_use: user says "make a Word doc", "put this in a document", "format this as a report/letter/proposal"; or a task calls for a .docx deliverable.
---

# Make doc

Lay finished prose into a clean `.docx` with real styles. The writing is `/draft`'s job; this skill formats it well.

## Library

Build with **python-docx** (MIT). Optional `.pdf` export via LibreOffice headless if present. No Python? Hand back the structured content and point to the runtime. On Cowork, defer the file mechanics to the built-in capability and apply these rules.

## House style

Read `project_brain/context.md` ("Office house style") for fonts, spacing, and any template. None set? Use one clean, consistent set and note it.

## The loop

1. **Content first.** The prose comes from `/draft` (write and finish it there). This skill takes finished text and structures it; don't draft and format in one muddle.
2. **Real styles.** Use heading styles (Heading 1/2), not bold-as-heading, so the structure and any table of contents work. Consistent body font, size, and spacing from house style.
3. **Generate.** Write a python-docx script: title, styled headings, paragraphs, lists, and tables where they help. Save to the vault. Export to PDF (LibreOffice) only if asked and available.
4. **Verify.** Open/inspect: styles applied (not manual formatting), structure intact. Fix what's off.
5. **Finish.** `/critique`, then `/done`.

## Anti-slop rules

- Heading styles, not manually bolded lines (so navigation and the TOC work).
- One consistent style set from house style; no font soup.
- Tables for tabular data, not tab-aligned text.

## Before "done"

- Real styles throughout (heading styles, not bold)?
- House style applied?
- Structure clean and navigable?
