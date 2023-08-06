import Foundation

public struct AnalyticsSession: Codable {
    var identifier: String
    var startedAt: Date
    var events: [AnalyticsEvent]
    var endedAt: Date
}
