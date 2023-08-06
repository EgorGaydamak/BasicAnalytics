import Foundation

//TODO: add missing methods

@objc(BAAnalytics)
public class AnalyticsObjCWrapper: NSObject {
    private var swiftAnalytics: Analytics
    
    @objc
    public init(configuration: ConfigurationObjCWrapper) {
        self.swiftAnalytics = Analytics(configuration: configuration.swiftConfiguration)
    }
    
    @objc
    public func startSession(
        completion: @escaping () -> Void,
        onError: @escaping (AnalyticsError) -> Void
    ) {
        self.swiftAnalytics.startSession { result in
            switch result {
            case .success():
                completion()
            case .failure(let error):
                onError(error)
            }
        }
    }
    
    @objc(trackEvent:)
    public func track(event: EventObjCWrapper) {
        self.swiftAnalytics.track(event: event.swiftEvent)
    }
    
    @objc
    public func endSession(
        completion: @escaping () -> Void,
        onError: @escaping (AnalyticsError) -> Void
    ) {
        self.swiftAnalytics.endSession { result in
            switch result {
            case .success():
                completion()
            case .failure(let error):
                onError(error)
            }
        }
    }
    
    @objc
    public func printLastSession() {
        swiftAnalytics.getLastSession { result in
            print(result)
        }
    }
}
