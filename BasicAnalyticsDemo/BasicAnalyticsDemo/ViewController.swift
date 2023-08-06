import UIKit

import BasicAnalytics

class ViewController: UIViewController {
    var analytics: Analytics? {
        return UIApplication.shared.delegate?.analytics
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onStartTap(_ sender: Any) {
        print("press start \(Date())")
        
        analytics?.startSession(completion: { result in
            print("analytics?.startSession \(result)")
        })
    }
    
    @IBAction func onEvent1Tap(_ sender: Any) {
        print("press 1 \(Date())")
        
        analytics?.track(event: .init(
            name: "1",
            properties: [
                "bool": .boolean(true),
                "string": .string("string")
            ]
        ))
    }
    
    @IBAction func onEvent2Tap(_ sender: Any) {
        print("press 2 \(Date())")
        
        analytics?.track(event: .init(name: "2"))
    }
    
    @IBAction func onEvent3Tap(_ sender: Any) {
        print("press 3 \(Date())")
        
        analytics?.track(event: .init(name: "3"))
    }
    
    @IBAction func onEndTap(_ sender: Any) {
        print("press end \(Date())")
        
        analytics?.endSession(completion: { result in
            print("analytics?.endSession \(result)")
        })
    }
    
    @IBAction func onLastTap(_ sender: Any) {
        print("press last \(Date())")
        
        analytics?.getLastSession(completion: { result in
            print("analytics?.getLastSession \(result)")
        })
    }
    
    @IBAction func onObjectiveCTestTap(_ sender: Any) {
        let objCClass = ObjectiveCAnalyticsUsageClass()
        objCClass.callSwiftMethodsFromAnalytics()
    }
}
