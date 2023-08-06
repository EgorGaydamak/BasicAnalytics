import Foundation

//TODO: add all other swift options to init

@objc(BAConfiguration)
public class ConfigurationObjCWrapper: NSObject {
    private(set) var swiftConfiguration: Configuration
    
    @objc
    public init(writingKey: String) {
        swiftConfiguration = Configuration(writingKey: writingKey)
    }
}
