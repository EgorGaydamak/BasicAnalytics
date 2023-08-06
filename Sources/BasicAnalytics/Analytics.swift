import Foundation

public enum AnalyticsError: Error {
    case noActiveSession
    case sessionAlreadyActive
    case sessionStartingError
    case sessionEndingError
    case sessionsFetchingError
    case storageErasingError
}

public final class Analytics {
    private let storage: AnalyticsSessionStorageInterface
    
    private var currentSessionId: String?
    private lazy var sessionAccessQueue = DispatchQueue(
        label: "de.basicAnalytics.sessionAccessQueue",
        attributes: .concurrent
    )
    
    //MARK: - Init
    
    public init(configuration: Configuration) {
        if let customStorage = configuration.customStorage {
            self.storage = customStorage
        } else {
            self.storage = AnalyticsSessionStorage(
                writingKey: configuration.writingKey,
                fileService: EventsFileService(),
                storageBatchSize: configuration.storageBatchSize
            )
        }
    }
    
    //MARK: - Session
    
    public func startSession(completion: @escaping (Result<Void, AnalyticsError>) -> Void) {
        sessionAccessQueue.async(flags: .barrier) {
            if self.currentSessionId != nil {
                completion(.failure(.sessionAlreadyActive))
                return
            }
            
            let id = UUID().uuidString
            self.currentSessionId = id
            
            self.storage.startSessionWriting(
                id: id,
                completion: { result in
                    switch result {
                    case .success():
                        completion(.success(()))
                    case .failure(_):
                        completion(.failure(.sessionStartingError))
                    }
                }
            )
        }
    }
    
    public func track(event: AnalyticsEvent) {
        sessionAccessQueue.async(flags: .barrier) {
            guard let currentSessionId = self.currentSessionId else { return }
            
            self.storage.appendEventToSession(
                with: currentSessionId,
                event: event,
                completion: { _ in
                    //TODO: event adding error handling can be implemented here 
                }
            )
        }
    }
    
    public func endSession(completion: @escaping (Result<Void, AnalyticsError>) -> Void) {
        sessionAccessQueue.async(flags: .barrier) {
            guard let currentSessionId = self.currentSessionId else {
                completion(.failure(.noActiveSession))
                return
            }
            
            self.storage.finishSessionWriting(
                id: currentSessionId,
                completion: { result in
                    switch result {
                    case .success():
                        self.currentSessionId = nil
                        completion(.success(()))
                    case .failure(_):
                        completion(.failure(.sessionEndingError))
                    }
                }
            )
        }
    }
    
    //MARK: - Storage
    
    public func getLastSession(completion: @escaping (Result<AnalyticsSession?, AnalyticsError>) -> Void) {
        sessionAccessQueue.async(flags: .barrier) {
            self.storage.getLastSession { result in
                switch result {
                case .success(let session):
                    completion(.success(session))
                case .failure(_):
                    completion(.failure(.sessionsFetchingError))
                }
            }
        }
    }
    
    public func eraseStorage(completion: @escaping (Result<Void, AnalyticsError>) -> Void) {
        storage.erase { result in
            switch result {
            case .success(let sessions):
                completion(.success(sessions))
            case .failure(_):
                completion(.failure(.storageErasingError))
            }
        }
    }
}
