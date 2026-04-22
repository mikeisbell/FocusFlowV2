# FocusFlow V2

## What this app is
An ADHD-first task dispatcher. One task shown at a time.
The app decides what to do next — the user does not manage a list.

## Non-obvious constraints
- Voice input is the primary add flow. Keyboard is a fallback, not equal.
- The scheduler must never show the user more than one pending task at a time.
- Task capture must require zero fields beyond the task description itself.
- Rescheduling must never show a penalty, streak break, or negative indicator.

## Skill index
Load the relevant skill before touching these subsystems:
- voice-input — Speech framework, permission flow, Claude transcript parsing
- scheduler — slot-finding logic, calendar availability, auto-scheduling rules
- swiftdata-models — model schema, migration plan
- calendar-access — EventKit integration, permission flow
