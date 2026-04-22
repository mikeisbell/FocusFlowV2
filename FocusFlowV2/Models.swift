import Foundation
import SwiftData

@Model
final class TaskItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date
    var scheduledFor: Date?
    var completedAt: Date?
    var skippedAt: Date?
    var orderIndex: Int

    init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = Date(),
        scheduledFor: Date? = nil,
        completedAt: Date? = nil,
        skippedAt: Date? = nil,
        orderIndex: Int = 0
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.scheduledFor = scheduledFor
        self.completedAt = completedAt
        self.skippedAt = skippedAt
        self.orderIndex = orderIndex
    }
}

@Model
final class UserSettings {
    @Attribute(.unique) var id: UUID
    var dayStartHour: Int
    var dayEndHour: Int
    var hasGrantedCalendarAccess: Bool
    var hasGrantedMicrophoneAccess: Bool

    init(
        id: UUID = UUID(),
        dayStartHour: Int = 9,
        dayEndHour: Int = 17,
        hasGrantedCalendarAccess: Bool = false,
        hasGrantedMicrophoneAccess: Bool = false
    ) {
        self.id = id
        self.dayStartHour = dayStartHour
        self.dayEndHour = dayEndHour
        self.hasGrantedCalendarAccess = hasGrantedCalendarAccess
        self.hasGrantedMicrophoneAccess = hasGrantedMicrophoneAccess
    }
}

@Model
final class ScheduledSlot {
    @Attribute(.unique) var id: UUID
    var date: Date
    var startTime: Date
    var endTime: Date
    // nil means this slot is a calendar block, not a user task
    var taskItem: TaskItem?
    var isCalendarBlock: Bool

    init(
        id: UUID = UUID(),
        date: Date,
        startTime: Date,
        endTime: Date,
        taskItem: TaskItem? = nil,
        isCalendarBlock: Bool = false
    ) {
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.taskItem = taskItem
        self.isCalendarBlock = isCalendarBlock
    }
}
