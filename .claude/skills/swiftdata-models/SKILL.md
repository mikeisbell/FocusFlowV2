# SwiftData Models

## Load this skill when
Changing any model schema or touching migration plans.

## Content

### Schema overview
Two models defined in `FocusFlowV2/Models.swift`. All use `@Attribute(.unique)` on `id: UUID`.

### TaskItem
Represents a user-created task. `completedAt` and `skippedAt` are mutually exclusive at runtime (enforce in service layer, not the model). `orderIndex` determines queue position — lower index means higher priority. Never let the user set it directly.

### UserSettings
Singleton in practice — one record per install. No enforcement of singularity in the model; the service layer must ensure only one instance is created.

### Project file registration
This project uses `PBXFileSystemSynchronizedRootGroup` (Xcode 16). Any Swift file added to the `FocusFlowV2/` directory is automatically compiled — no need to edit `.xcodeproj`.

### ModelContainer
`FocusFlowV2App.swift` registers `TaskItem` and `UserSettings` with `AppMigrationPlan`. The migration plan defines SchemaV1 (1,0,0) → SchemaV2 (2,0,0) as a lightweight stage. A try/catch fallback recreates the container without the migration plan if migration fails (dev builds only).

### Migration history
- V1 → V2 (queue refactor): removed `scheduledFor: Date?` from `TaskItem`, removed `ScheduledSlot` model entirely, removed `hasGrantedCalendarAccess: Bool` from `UserSettings`.
