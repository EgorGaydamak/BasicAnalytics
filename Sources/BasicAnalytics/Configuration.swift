import Foundation

/**
 Represents the configuration settings for the analytics system.

 Use this struct to define configuration settings for the analytics system. The configuration includes details such as the writing key, storage batch size, and an optional custom storage implementation.

 - Note: The `Configuration` struct provides flexibility in configuring the behavior of the analytics system, allowing you to customize settings like the storage batch size and provide a custom storage implementation if desired.
 - Important: When initializing a `Configuration` instance, provide a valid writing key. You can also specify a storage batch size and a custom storage implementation to tailor the analytics system to your needs.
 */
public struct Configuration {
    enum Const {
        static let defaultStorageBatchSize: Int = 10
    }
    
    let writingKey: String
    let storageBatchSize: Int
    var customStorage: AnalyticsSessionStorageInterface?
    
    /**
     Initializes a configuration instance for the analytics system.
     
     Use this initializer to create a configuration instance with the specified settings.
     
     - Parameter writingKey: The writing key associated with the analytics system.
     - Parameter storageBatchSize: The storage batch size. Used to access memory not on every event. If not provided, the default batch size will be used.
     - Parameter customStorage: An optional custom storage implementation. If not provided, the system will use the default storage.
     */
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
