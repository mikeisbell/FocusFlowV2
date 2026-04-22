# SwiftData Models

## Load this skill when
Changing any model schema or touching migration plans.

## Content

### Schema overview
Three models defined in `FocusFlowV2/Models.swift`. All use `@Attribute(.unique)` on `id: UUID`.

### TaskItem
Represents a user-created task. `scheduledFor` is nil until the scheduler assigns a slot. `completedAt` and `skippedAt` are mutually exclusive at runtime (enforce in service layer, not the model). `orderIndex` is scheduler-assigned — never let the user set it.

### UserSettings
Singleton in practice — one record per install. No enforcement of singularity in the model; the service layer must ensure only one instance is created.

### ScheduledSlot
Links to `TaskItem?` with SwiftData's default `.nullify` delete rule — if the task is deleted, the slot's `taskItem` becomes nil rather than cascading. `isCalendarBlock: true` + `taskItem: nil` is the canonical state for EventKit-sourced blocks. Never set `isCalendarBlock: true` and also assign a `taskItem`.

### Project file registration
This project uses `PBXFileSystemSynchronizedRootGroup` (Xcode 16). Any Swift file added to the `FocusFlowV2/` directory is automatically compiled — no need to edit `.xcodeproj`.

### ModelContainer
`FocusFlowV2App.swift` currently registers only `Item` in the schema (Xcode default). When hooking up the real models for persistence, update that schema to include `TaskItem`, `UserSettings`, and `ScheduledSlot`. That file is Xcode-generated; confirm with the user before modifying it.
