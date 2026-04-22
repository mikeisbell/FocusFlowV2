import Foundation
import SwiftData

@Model
final class TaskItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date
    var completedAt: Date?
    var skippedAt: Date?
    var orderIndex: Int

    init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        skippedAt: Date? = nil,
        orderIndex: Int = 0
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
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
    var hasGrantedMicrophoneAccess: Bool

    init(
        id: UUID = UUID(),
        dayStartHour: Int = 9,
        dayEndHour: Int = 17,
        hasGrantedMicrophoneAccess: Bool = false
    ) {
        self.id = id
        self.dayStartHour = dayStartHour
        self.dayEndHour = dayEndHour
        self.hasGrantedMicrophoneAccess = hasGrantedMicrophoneAccess
    }
}
