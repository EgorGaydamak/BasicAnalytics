import Foundation

public struct AnalyticsEvent: Codable {
    public init(name: String,
                timestamp: Date = Date(),
                properties: [String : AnalyticsEventPropertyValue]? = nil
    ) {
        self.name = name
        self.timestamp = timestamp
        self.properties = properties
    }
    
    public var name: String
    public var timestamp: Date
    public var properties: [String: AnalyticsEventPropertyValue]?
}

extension AnalyticsEvent: Equatable {
    public static func == (lhs: AnalyticsEvent, rhs: AnalyticsEvent) -> Bool {
        return lhs.name == rhs.name &&
        lhs.timestamp == rhs.timestamp &&
        lhs.properties == rhs.properties
    }
}
