import Foundation

public struct Configuration {
    enum Const {
        static let defaultStorageBatchSize: Int = 10
    }
    
    let writingKey: String
    let storageBatchSize: Int
    var customStorage: AnalyticsSessionStorageInterface?
    
    public init(
        writingKey: String,
        storageBatchSize: Int? = nil,
        customStorage: AnalyticsSessionStorageInterface? = nil
    ) {
        self.writingKey = writingKey
        self.storageBatchSize = storageBatchSize ?? Const.defaultStorageBatchSize
        self.customStorage = customStorage
    }
}
