# Scheduler

## Load this skill when
Touching slot-finding logic, calendar availability queries, or auto-scheduling rules.

## Content

### Current implementation
`SchedulerService.swift` contains a single static method: `nextAvailableSlot(after:) -> Date`. It returns the top of the next clock hour after the given date — e.g. 9:30 AM → 10:00 AM, 9:00 AM → 10:00 AM. It uses `Calendar.dateComponents` to zero out minutes/seconds/nanoseconds and increment the hour component.

### Constraints discovered
- The method strips the current hour's minutes, so any call made within an hour gets the same slot as a call at :00 of that hour. This is intentional: slots are hour-granular.
- Crossing midnight (23:xx → 00:xx next day) is handled correctly by Calendar date arithmetic — no manual day rollover needed.
- `orderIndex` is currently hardcoded to 0 on all tasks created through AddView. When a real queue is introduced, this method will need to return or accept a position in the day's ordered list. Do not rely on `orderIndex` being meaningful until the scheduler is fully built.

### What's not implemented yet
- Calendar availability check (EventKit integration not yet built)
- Day boundary enforcement (`dayStartHour` / `dayEndHour` from `UserSettings`)
- Conflict detection (two tasks at the same hour)
- Queue ordering beyond `orderIndex: 0`
