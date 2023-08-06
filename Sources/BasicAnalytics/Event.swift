import Foundation

/**
 Represents an analytics event that can be tracked.

 Use this struct to define individual analytics events that can be tracked within the system. Each event has a name, timestamp, and optional properties associated with it.
 */
public struct AnalyticsEvent: Codable {
    /**
     Initializes an analytics event instance.
     
     Use this initializer to create an event instance with the specified settings.
     
     - Parameter name: The name of the analytics event.
     - Parameter timestamp: The timestamp when the event occurred. If not provided, the current date and time will be used.
     - Parameter properties: Optional properties associated with the event. Use this dictionary to provide additional information about the event.
     */
    public init(
        name: String,
        timestamp: Date = Date(),
        properties: [String : AnalyticsEventPropertyValue]? = nil
    ) {
        self.name = name
        self.timestamp = timestamp
        self.properties = properties
    }
    
    /// The name of the analytics event.
    public var name: String
    
    /// The timestamp when the event occurred.
    public var timestamp: Date
    
    /// Optional properties associated with the event.
    public var properties: [String: AnalyticsEventPropertyValue]?
}

extension AnalyticsEvent: Equatable {
    public static func == (lhs: AnalyticsEvent, rhs: AnalyticsEvent) -> Bool {
        return lhs.name == rhs.name &&
        lhs.timestamp == rhs.timestamp &&
        lhs.properties == rhs.properties
    }
}
