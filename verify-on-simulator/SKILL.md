---
name: verify-on-simulator
description: >-
  Manually verify UI features on an iOS or macOS simulator after unit tests pass
  — when to delegate, how to brief a subagent, screenshot tap coordinates, and
  safety rules. Use when finishing a UI feature, before shipping, or when tests
  are green but "nothing happens" bugs are suspected. Delegate the actual driving
  to a smaller-model subagent (e.g. simulator-verifier).
---

# Verify on Simulator

**A green test suite does not mean the feature works.** UI bugs that tests miss
are often *nothing happens* failures — inert taps, `.task` on conditional views,
unreachable menus, mis-placed `.searchable`, missing `navigationDestination`
registrations. Catch these by **driving the feature on a simulator**.

This skill covers **when** to verify, **how to delegate**, and **how to brief**
the agent doing the driving. Project-specific build commands and off-limits
controls live in the repo's `CLAUDE.md` (or equivalent).

## When to use

- After implementing or changing UI navigation, lists, sheets, search, swipe
  actions, context menus, or empty states
- Before marking a UI feature done or opening a PR
- When unit/UI tests pass but manual behavior is unconfirmed

Skip when the change is logic-only (no new taps, pushes, or visible flows).

## Delegate to a subagent

Simulator verification is **screenshot-heavy and iterative** — dozens of
screenshot → tap → screenshot cycles. That burns expensive context on mechanical
work.

**Hand driving to a smaller-model subagent** (e.g. `simulator-verifier` with
Sonnet or Haiku), not the main model. Keep on the main model:

- API/protocol contracts and credential handling
- Architecture decisions
- Writing the verification checklist itself

Launch the subagent with this skill plus the repo's build/run section.

## Before delegating — main model checklist

1. **Build and install** on simulator (from project docs):
   ```bash
   # Example — replace with project CLAUDE.md commands
   xcodebuild -project <Project>.xcodeproj -scheme <Scheme> -configuration Debug \
     -destination 'platform=iOS Simulator,name=<Device>'
   ```
2. **Boot the simulator** and note the **UDID** (`xcrun simctl list devices booted`).
3. **Write a numbered checklist** — one line per tap path to verify (not vague
   "test the feature").
4. **List off-limits controls** from project docs (merge buttons, delete, submit
   forms that mutate production, payment, etc.).
5. **Launch subagent** with: UDID, checklist, this skill, and `CLAUDE.md`
   build/run + testing sections.

## Briefing the simulator agent

Include all of the following in the subagent prompt:

| Item | Detail |
|------|--------|
| **Device** | Booted simulator **UDID** — not a device name |
| **Checklist** | Numbered checks; expect **PASS / FAIL / BLOCKED** per item |
| **Credentials** | Explicitly: do **not** enter credentials |
| **Data** | Do **not** mutate real/production data — opening a sheet to check focus is OK; submitting is not |
| **Destructive UI** | Name specific buttons/controls that are off-limits and where they appear (e.g. bottom action bar merge button) |
| **Reporting** | Require stating what could *not* be verified; "probably fine" is not PASS |
| **Accidents** | Report any accidental tap or state change immediately |

### Tap coordinates — critical

Tap/swipe coordinates are **device points, not screenshot pixels**. Convert by
*fraction of the image*, never by the device's native scale factor:

```
x_points = (x_pixels / screenshot_width_pixels)  * reported_width_points
y_points = (y_pixels / screenshot_height_pixels) * reported_height_points
```

The simulator MCP tool reports point space on every attach/launch (e.g.
`402x874 points`) — **that is the authority**.

Do **not** assume "screenshot is ~3x point dimensions, divide by 3." The tool
often downsamples before returning the image, so the true factor differs from
the device scale. Wrong conversion overshoots taps — especially dangerous on
compact toolbars and bottom action bars where destructive buttons live. Large
targets (tab bar) may still land by luck, which hides the error until a
critical control is hit.

## What to drive

For each new or changed UI surface:

- Tap every new row — confirm navigation pushes
- Confirm each list loads (not stuck idle/loading forever)
- Reach swipe actions and context menus — not just primary tap
- Check empty states and error states if triggerable without mutating data
- Exercise search fields — cursor, keyboard, typed text visible
- Back navigation returns to expected screen

## Result format

Subagent returns a table or list:

```
| # | Check | Result | Notes |
|---|-------|--------|-------|
| 1 | Tap repo row → detail | PASS | |
| 2 | Swipe delete on entry | FAIL | Menu never appears |
| 3 | Create PR submit | BLOCKED | No fixture account |
```

Any **FAIL** blocks ship until fixed or explicitly accepted. **BLOCKED** items
need a documented reason (missing fixture, needs credentials, etc.).

## Platform notes

- **iOS Simulator:** primary target for this skill
- **macOS:** same coordinate rules if using screenshot-based driving
- **Native apps only** — not applicable to web or Docker-hosted UIs

Resolve build/test commands from the **project repo**, not this skill.
