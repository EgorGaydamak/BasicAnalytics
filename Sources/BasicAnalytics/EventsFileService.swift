import Foundation

struct StorableEvent: Codable, Equatable {
    enum EventType: Codable {
        case sessionStart
        case trackingEvent(name: String, properties: [String: AnalyticsEventPropertyValue]?)
        case sessionEnd
        
        static func == (lhs: EventType, rhs: EventType) -> Bool {
            switch (lhs, rhs) {
            case (.sessionStart, .sessionStart):
                return true
            case let (.trackingEvent(name1, properties1), .trackingEvent(name2, properties2)):
                return name1 == name2 && properties1 == properties2
            case (.sessionEnd, .sessionEnd):
                return true
            default:
                return false
            }
        }
    }
    
    var timestamp: Date
    var type: EventType
    
    init(type: EventType) {
        self.timestamp = Date()
        self.type = type
    }
    
    static func == (lhs: StorableEvent, rhs: StorableEvent) -> Bool {
        return lhs.timestamp == rhs.timestamp && lhs.type == rhs.type
    }
}

protocol EventsFileServiceInterface {
    func getFileURL(writingKey: String, sessionID: String) -> URL
    
    func saveOrAppend(
        events: [StorableEvent],
        to fileURL: URL,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    
    func retrieveEventsFromFile(
        at fileURL: URL,
        completion: @escaping (Result<[StorableEvent]?, Error>) -> Void
    )
    
    func erase(writingKey: String, completion: (Result<Void, Error>) -> Void)
}

class EventsFileService: EventsFileServiceInterface {
    private func getDirectoryURL(for writingKey: String) -> URL {
        let documentsDirectoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = documentsDirectoryURLs[0]
        let directoryURL = docURL.appendingPathComponent("BasicAnalytics/\(writingKey)/")
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        
        return directoryURL
    }
    
    func getFileURL(writingKey: String, sessionID: String) -> URL {
        let directoryURL = getDirectoryURL(for: writingKey)
        let fileURL = directoryURL.appendingPathComponent("\(sessionID).json")
        
        return fileURL
    }
    
    func saveOrAppend(events: [StorableEvent], to fileURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            retrieveEventsFromFile(at: fileURL) { result in
                switch result {
                case .success(let retrievedEvents):
                    do {
                        var eventsToAppend = events
                        
                        if let retrievedEvents = retrievedEvents {
                            eventsToAppend.append(contentsOf: retrievedEvents)
                        }
                        
                        let encoder = JSONEncoder()
                        encoder.dateEncodingStrategy = .iso8601
                        
                        let jsonData = try encoder.encode(eventsToAppend)
                        
                        try FileManager.default.removeItem(at: fileURL)
                        try jsonData.write(to: fileURL)
                        
                        completion(.success(()))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                
                let jsonData = try encoder.encode(events)
                try jsonData.write(to: fileURL)
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    
    func retrieveEventsFromFile(at fileURL: URL, completion: @escaping (Result<[StorableEvent]?, Error>) -> Void) {
        do {
            let jsonData = try Data(contentsOf: fileURL)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let events = try decoder.decode([StorableEvent].self, from: jsonData)
            
            completion(.success(events))
        } catch {
            completion(.failure(error))
        }
    }
    
    func erase(writingKey: String, completion: (Result<Void, Error>) -> Void) {
        let directoryURL = getDirectoryURL(for: writingKey)
        do {
            try FileManager.default.removeItem(at: directoryURL)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
