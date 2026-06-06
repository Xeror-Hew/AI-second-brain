---
name: make-sheet
description: Produce an Excel (.xlsx) spreadsheet with real formulas, clean structure, and no hard-coded numbers.
when_to_use: user says "make a spreadsheet", "build a sheet", "put this in Excel", "a model/tracker/budget"; or a task calls for a spreadsheet as the deliverable.
---

# Make sheet

Produce a real `.xlsx` that computes, not a table of frozen numbers. The structure and the formulas are the point.

## Library

Build with **openpyxl** (plus **pandas** for data shaping) — MIT/BSD. openpyxl writes formula strings but no cached results, so a fresh file shows blanks until it's opened in Excel. If **LibreOffice** is present, recalc headless so values are filled, and scan for `#REF!` / `#DIV/0!` / `#VALUE!`; if not, write the formulas and tell the user they compute on open. No Python? Hand back the structure and point to the runtime. On Cowork, defer the file mechanics to the built-in capability and apply these rules.

## House style

Read `project_brain/context.md` ("Office house style") for palette and fonts: header fill and font, currency/number/date formats, and the fill that marks input vs computed cells. None set? Use one clean, consistent set and note it.

## The loop

1. **Model it.** Lay out columns, units, and which cells are inputs vs computed before writing. Run `/check-library` for an existing sheet to build on.
2. **Real formulas, never hard-coded.** Computed cells are formulas (`=SUM(...)`, `=B2*C2`) referencing inputs. A number a reader could change is a labeled input cell.
3. **Generate.** Write an openpyxl script: a frozen header row, number/date/currency formats and header styling from house style, one total or check row, no magic constants buried in formulas.
4. **Recalc + check.** LibreOffice recalc if present; confirm no error cells and the totals are right. Else note that the formulas evaluate on open.
5. **Finish.** `/critique`, then `/done`.

## Anti-slop rules

- No hard-coded results where a formula belongs.
- Inputs and computed cells are visually distinct (a fill, or a labeled input block).
- Units and formats explicit (%, currency, dates), not raw floats.
- One source of truth per number; downstream cells reference it.

## Before "done"

- Computed cells are formulas, not pasted values?
- No error cells; totals verified (recalced, or flagged as compute-on-open)?
- Inputs labeled and distinct?
- House style applied (header, number/currency formats, input vs computed)?
