# Memory Note Organizer Final Parity Audit

This document compares `/Users/kevin/Projects/FlutterApps/memory_note_organizer` with `/Users/kevin/Projects/FlutterApps/memory_notes` as of March 22, 2026.

## Parity Status

### Implemented In `memory_notes`

- Supabase-backed auth and app startup bootstrap
- Feature-based package layout under `lib/app`, `lib/core`, and `lib/features`
- Signals-based state management replacing Riverpod for the new app
- Task file, category, task, and current-state data models
- CRUD for files, categories, and tasks
- Dedicated controllers/stores/query services for notes
- Separate `CategoryController` and task controller
- Organizer-style saved open-file restore via `CurrentState.currentFiles`
- Adaptive notes UI:
  - mobile stacked navigation
  - desktop split workspace
  - task drilldown columns
  - notes pane for selected task
- Search across files, categories, and tasks
- Speech dictation support
- Duplicate file/category/task support
- Realtime sync service through `supa_manager`
- Unit tests around query, workspace controller, workspace store, and sync policy

### Mostly Implemented But Still Needs Validation / Polish

- Desktop realtime sync behavior
  - realtime subscriptions are wired up and events are arriving
  - file/category/task refresh logic exists
  - desktop sync has improved substantially, but it still needs confidence testing across real cross-device insert/update/delete flows
- Desktop workspace UX
  - major layout and action cleanup has been done
  - more refinement is still needed so create/edit/delete flows are as obvious as the organizer app
- Open file workflow
  - explicit `Open List` dialog is implemented
  - overall open/close/reopen workflow is cleaner than before but still lighter than the organizer app

## Present In Organizer But Still Missing Or Reduced

### High Priority Missing / Reduced

- Full desktop sync confidence parity
  - organizer app has a more mature in-memory update path around remote events
  - `memory_notes` still needs confirmation that all remote inserts, updates, and deletes are reflected reliably in desktop UI state
- Rich desktop command/action surface
  - organizer has denser file/category/task action coverage through menus/dialogs
  - `memory_notes` currently has a slimmer action surface after simplification
- Widget/integration coverage for real desktop flows
  - current tests are mostly application-layer tests
  - organizer behavior would benefit from UI-level regression tests for:
    - open list
    - create category
    - create task
    - delete task
    - remote update/delete refresh
- Desktop keyboard interaction parity
  - organizer has dedicated tree keyboard handling and shortcut-driven flows
  - `memory_notes` currently relies primarily on pointer/tap interaction

### Medium Priority Missing / Reduced

- Theme system parity
  - organizer has persisted multi-theme support (`seaFoam`, `softBlue`, `sunset`, `deepBlue`, `dark`)
  - `memory_notes` now has a cleaner blue palette, but still only exposes a single theme and no theme picker
- Logging / diagnostics UI
  - organizer has log container / log dialog tooling
  - `memory_notes` logs to console but has no in-app logs UI
- About / utility dialogs
  - organizer has dedicated `about`, `theme`, `open`, `rename`, `duplicate`, `new item`, and log dialogs
  - `memory_notes` has the core working prompts, but not the broader utility/dialog surface
- Search dialog / broader desktop utility dialogs
  - organizer includes additional dialogs like dedicated search/open/rename/new/duplicate flows
  - `memory_notes` has the core ones needed for current flows, but not the broader utility/dialog ecosystem
- Mobile navigation-state synchronization depth
  - organizer has explicit mobile navigation-stack resync logic after mutations
  - `memory_notes` mobile flows work, but the state model is lighter

### Low Priority / Optional Depending On Scope

- Voice command parser / executor
  - organizer has command parsing and execution beyond speech dictation
  - `memory_notes` currently supports dictation, not command-mode voice control
- Favorite files flows
  - not re-added because they do not appear to be part of the desired current app behavior
- Connectivity manager / event publisher architecture
  - organizer has more infrastructure around events and app-wide coordination
  - `memory_notes` has a simpler direct-controller/store model
- Desktop search parity
  - organizer has a dedicated search dialog and search-results dialog flow
  - `memory_notes` has a search screen, which is simpler but not identical in interaction model
- Logs/about/theme dialog ecosystem
  - nice-to-have parity items, not core note-taking blockers

## Current Recommendation

### 1. Finish Desktop Realtime Confidence

This is the main remaining functional risk.

Needed:

- verify remote insert/update/delete for:
  - files
  - categories
  - tasks
- especially verify desktop UI reactions when:
  - selected task is deleted remotely
  - category count changes remotely
  - task notes change remotely

### 2. Add Desktop Widget Tests

Suggested tests:

- open list from workspace menu
- create category and auto-select it
- create task and auto-select it
- remote task delete removes visible row
- remote category update refreshes sidebar/category counts
- remote task rename/update refreshes visible notes pane and selected row

### 3. Decide Scope For Organizer Utility Features

The largest remaining parity questions are now product-scope questions rather than migration blockers:

- do we want multi-theme selection again?
- do we want an in-app logs dialog?
- do we want desktop keyboard shortcuts/tree navigation?
- do we want voice commands beyond dictation?

### 4. Final UX Parity Sweep

After sync is fully trustworthy, do one last pass comparing daily-use flows against the organizer app:

- list actions
- category actions
- task actions
- desktop discoverability
- mobile navigation feel

## Summary

`memory_notes` is no longer in the early migration stage. The core architecture migration is effectively complete, and most of the organizer app's important end-user note features now exist in the new app.

The biggest remaining gap is not package structure or missing CRUD anymore. It is confidence and polish:

- reliable desktop realtime behavior
- a final organizer-style UX parity sweep
- stronger UI-level regression tests
- a product decision on whether to restore organizer utility features like theme switching, logs UI, desktop shortcuts, and voice commands
