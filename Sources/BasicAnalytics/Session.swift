import Foundation

/**
 Represents an analytics session with associated events.
 */
public struct AnalyticsSession: Codable {
    /// The unique identifier of the analytics session.
    var identifier: String
    
    /// The timestamp when the session started.
    var startedAt: Date
    
    /// The sequence of events recorded during the session.
    var events: [AnalyticsEvent]
    
    /// The timestamp when the session ended.
    var endedAt: Date
}
