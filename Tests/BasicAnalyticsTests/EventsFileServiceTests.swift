import XCTest
@testable import BasicAnalytics // Import your module

class EventsFileServiceTests: XCTestCase {
    let eventsFileService = EventsFileService()
    let writingKey = "testWritingKey"
    
    func testFileURLCreation() {
        let sessionID = "testSessionID"
        
        let fileURL = eventsFileService.getFileURL(writingKey: writingKey, sessionID: sessionID)
        
        let expectedDirectoryPathComponent = "BasicAnalytics/\(writingKey)/"
        let expectedFilePathComponent = "\(sessionID).json"
        
        XCTAssertEqual(fileURL.lastPathComponent, expectedFilePathComponent)
        XCTAssertTrue(fileURL.path.contains(expectedDirectoryPathComponent))
    }
    
    func testSaveAndRetrieveEvents() {
        let fileURL = eventsFileService.getFileURL(writingKey: writingKey, sessionID: "sessionID")
        
        let event1 = StorableEvent(type: .sessionStart)
        let event2 = StorableEvent(type: .trackingEvent(name: "EventName", properties: nil))
        let event3 = StorableEvent(type: .sessionEnd)
        let events = [event1, event2, event3]
        
        let saveExpectation = expectation(description: "Save events expectation")
        let retrieveExpectation = expectation(description: "Retrieve events expectation")
        
        eventsFileService.saveOrAppend(events: events, to: fileURL) { result in
            switch result {
            case .success:
                saveExpectation.fulfill()
                
                self.eventsFileService.retrieveEventsFromFile(at: fileURL) { result in
                    switch result {
                    case .success(let retrievedEvents):
                        guard let retrievedEvents else {
                            XCTFail("Failed to retrieve events")
                            return
                        }
                        XCTAssertEqual(retrievedEvents.count, events.count)
                        retrieveExpectation.fulfill()
                    case .failure:
                        XCTFail("Failed to retrieve events")
                    }
                }
                
            case .failure:
                XCTFail("Failed to save events")
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    //....
    
    override func tearDown() {
        eventsFileService.erase(
            writingKey: self.writingKey) { _ in
                super.tearDown()
            }
    }
}
