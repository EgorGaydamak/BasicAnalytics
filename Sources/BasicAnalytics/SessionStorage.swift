import Foundation

public enum AnalyticsSessionStorageError: Error {
    case fileServiceError
}

public protocol AnalyticsSessionStorageInterface {
    func startSessionWriting(
        id: String,
        completion: @escaping (Result<Void, AnalyticsSessionStorageError>) -> Void
    )
    
    func appendEventToSession(
        with id: String,
        event: AnalyticsEvent,
        completion: @escaping (Result<Void, AnalyticsSessionStorageError>) -> Void
    )
    
    func finishSessionWriting(
        id: String,
        completion: @escaping (Result<Void, AnalyticsSessionStorageError>) -> Void
    )
    
    func getLastSession(
        completion: @escaping (Result<AnalyticsSession?, AnalyticsSessionStorageError>) -> Void
    )
    
    func erase(
        completion: @escaping (Result<Void, AnalyticsSessionStorageError>) -> Void
    )
}

final class AnalyticsSessionStorage: AnalyticsSessionStorageInterface {
    private enum Const {
        static let lastEndedSessionIDKey: String = "lastEndedSessionIDKey"
    }
    
    private let fileService: EventsFileServiceInterface
    private let writingKey: String
    private let storageBatchSize: Int
    
    private var eventsToWriteBySessionID: [String: [StorableEvent]] = [:]
    
    init(
        writingKey: String,
        fileService: EventsFileServiceInterface,
        storageBatchSize: Int
    ) {
        self.writingKey = writingKey
        self.fileService = fileService
        self.storageBatchSize = storageBatchSize
    }
    
    func startSessionWriting(
        id: String,
        completion: @escaping (Result<Void, AnalyticsSessionStorageError>) -> Void
    ) {
        let fileURL = fileService.getFileURL(writingKey: writingKey, sessionID: id)
        fileService.saveOrAppend(
            events: [ .init(type: .sessionStart) ],
            to: fileURL,
            completion: { result in
                switch result {
                case .success():
                    completion(.success(()))
                case .failure(_):
                    completion(.failure(.fileServiceError))
                }
            }
        )
    }
    
    func appendEventToSession(
        with id: String,
        event: AnalyticsEvent,
        completion: @escaping (Result<Void, AnalyticsSessionStorageError>) -> Void
    ) {
        let storableEvent = StorableEvent(type: .trackingEvent(
            name: event.name,
            properties: event.properties)
        )
        
        eventsToWriteBySessionID[id, default: []].append(storableEvent)
        
        if eventsToWriteBySessionID[id, default: []].count >= storageBatchSize {
            fileService.saveOrAppend(
                events: eventsToWriteBySessionID[id] ?? [],
                to: fileService.getFileURL(writingKey: writingKey, sessionID: id),
                completion: { result in
                    switch result {
                    case .success():
                        self.eventsToWriteBySessionID[id] = []
                    case .failure(_):
                        completion(.failure(.fileServiceError))
                    }
                }
            )
        }
    }
    
    func finishSessionWriting(
        id: String,
        completion: @escaping (Result<Void, AnalyticsSessionStorageError>) -> Void
    ) {
        let fileURL = fileService.getFileURL(writingKey: writingKey, sessionID: id)
        fileService.saveOrAppend(
            events: (eventsToWriteBySessionID[id] ?? []) + [ .init(type: .sessionEnd) ],
            to: fileURL,
            completion: { result in
                switch result {
                case .success():
                    UserDefaults.standard.setValue(id, forKey: Const.lastEndedSessionIDKey)
                    self.eventsToWriteBySessionID[id] = []
                    
                    completion(.success(()))
                case .failure(_):
                    completion(.failure(.fileServiceError))
                }
            }
        )
    }
    
    func getLastSession(
        completion: @escaping (Result<AnalyticsSession?, AnalyticsSessionStorageError>) -> Void
    ) {
        if let lastSessionID = UserDefaults.standard.string(forKey: Const.lastEndedSessionIDKey) {
            fileService.retrieveEventsFromFile(
                at: fileService.getFileURL(writingKey: writingKey, sessionID: lastSessionID),
                completion: { result in
                    switch result {
                    case .success(let events):
                        completion(.success(.init(id: lastSessionID, storableEvents: events)))
                    case .failure(_):
                        completion(.failure(.fileServiceError))
                    }
                }
            )
        }
    }
    
    func erase(
        completion: @escaping (Result<Void, AnalyticsSessionStorageError>) -> Void
    ) {
        fileService.erase(writingKey: writingKey, completion: { result in
            switch result {
            case .success():
                completion(.success(()))
            case .failure(_):
                completion(.failure(.fileServiceError))
            }
        })
    }
}

extension AnalyticsSession {
    init?(
        id: String,
        storableEvents: [StorableEvent]?
    ) {
        guard let storableEvents,
                  storableEvents.count >= 2 //at least start and stop
        else { return nil }
        
        var startedAtToAdd: Date = Date()
        var eventsToAdd: [AnalyticsEvent] = []
        var endedAtToAdd: Date = Date()
        
        for event in storableEvents {
            switch event.type {
            case .sessionStart:
                startedAtToAdd = event.timestamp
            case .trackingEvent(name: let name, properties: let properties):
                eventsToAdd.append(.init(
                    name: name,
                    timestamp: event.timestamp,
                    properties: properties
                ))
            case .sessionEnd:
                endedAtToAdd = event.timestamp
            }
        }
        
        self.identifier = id
        self.startedAt = startedAtToAdd
        self.events = eventsToAdd
        self.endedAt = endedAtToAdd
    }
}
