import Foundation

//TODO: support parameters and timestamp setting in init

@objc(BAEvent)
public class EventObjCWrapper: NSObject {
    private(set) var swiftEvent: AnalyticsEvent
    
    @objc
    public init(name: String) {
        self.swiftEvent = AnalyticsEvent(name: name)
    }
}
