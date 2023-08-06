import Foundation

public enum AnalyticsEventPropertyValue: Codable {
    case string(String)
    case int(Int)
    case boolean(Bool)
    // Add more cases for other types as needed

    enum CodingKeys: String, CodingKey {
        case string, int, boolean
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decode(String.self, forKey: .string) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self, forKey: .int) {
            self = .int(value)
        } else if let value = try? container.decode(Bool.self, forKey: .boolean) {
            self = .boolean(value)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unsupported property value type"
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .string(let value):
            try container.encode(value, forKey: .string)
        case .int(let value):
            try container.encode(value, forKey: .int)
        case .boolean(let value):
            try container.encode(value, forKey: .boolean)
        }
    }
}

extension AnalyticsEventPropertyValue: Equatable {
    public static func == (lhs: AnalyticsEventPropertyValue, rhs: AnalyticsEventPropertyValue) -> Bool {
        switch (lhs, rhs) {
        case (.string(let leftValue), .string(let rightValue)):
            return leftValue == rightValue
        case (.int(let leftValue), .int(let rightValue)):
            return leftValue == rightValue
        case (.boolean(let leftValue), .boolean(let rightValue)):
            return leftValue == rightValue
        default:
            return false
        }
    }
}
