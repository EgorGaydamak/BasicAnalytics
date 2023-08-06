import Foundation

@objc
public enum AnalyticsError: Int, Error {
    case noActiveSession
    case sessionAlreadyActive
    case sessionStartingError
    case sessionEndingError
    case sessionsFetchingError
    case storageErasingError
}

/**
 Main class of the analytics SDK.
 
 Use this class to manage analytics sessions, track events, and perform data storage operations.
 
 - Important: Make sure to initialize an instance of this class at your app's start and maintain a reference to it.
 
 - Note:  I recommend initializing an instance of `Analytics` inside the `func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool` function of your `AppDelegate.swift` file.
 */
public final class Analytics {
    private let storage: AnalyticsSessionStorageInterface
    
    private var currentSessionId: String?
    private lazy var sessionAccessQueue = DispatchQueue(
        label: "de.basicAnalytics.sessionAccessQueue",
        attributes: .concurrent
    )
    
    //MARK: - Init
    
    /**
     Initializes an analytics instance with the provided configuration.

     Use this method to create an analytics instance with the specified configuration.

     - Parameter configuration: The `Configuration` object containing the necessary settings for analytics.
     
     - Note: If a custom storage is provided in the configuration, it will be used for storing analytics data. Otherwise, a default `AnalyticsSessionStorage` instance will be created.

     - Returns: An initialized `Analytics` instance.
     */
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
    
    /**
     Starts a new analytics session.

     Use this method to begin a new analytics session. If a session is already active, this method will return an error.

     - Parameter completion: A closure that is called when the session start operation is completed.
        - Parameter result: A `Result` enum indicating the outcome of the operation. If the operation is successful, the `Result` will contain `.success(Void)`. If the operation fails, it will contain `.failure(AnalyticsError)`.

     - Note: A session can only be started if there is no active session in progress. If an active session already exists, an error of type `AnalyticsError.sessionAlreadyActive` will be returned.

     - Returns: Nothing.
     */
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
    
    /**
     Tracks an analytics event within the current session.

     Use this method to record an analytics event within the active session. The event will be added to the session's event log.

     - Parameter event: The `AnalyticsEvent` to be tracked.

     - Note: The event will only be tracked if there is an active session. If no active session is present, the event will not be recorded.

     - Important: The event tracking is performed asynchronously within the session access queue.

     - Returns: Nothing.
     */
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
    
    /**
     Ends the currently active analytics session.

     Use this method to conclude the active analytics session. If no active session is present, an error will be returned in `completion`.

     - Parameter completion: A closure that is called when the session end operation is completed.
        - Parameter result: A `Result` enum indicating the outcome of the operation. If the operation is successful, the `Result` will contain `.success(Void)`. If the operation fails, it will contain `.failure(AnalyticsError)`.

     - Note: An active session must be present for it to be ended. If no active session is found, an error of type `AnalyticsError.noActiveSession` will be returned.

     - Returns: Nothing.
     */
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
    
    /**
     Retrieves the most recent analytics session.

     Use this method to fetch the details of the most recent analytics session, if any.

     - Parameter completion: A closure that is called when the session retrieval operation is completed.
        - Parameter result: A `Result` enum indicating the outcome of the operation. If the operation is successful, the `Result` will contain `.success(AnalyticsSession?)`, where the associated value is an optional `AnalyticsSession` object representing the most recent session. If the operation fails, it will contain `.failure(AnalyticsError)`.

     - Returns: Nothing.
     */
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
    
    /**
     Erases all stored analytics data.

     Use this method to erase all stored analytics data, including session history and events.

     - Parameter completion: A closure that is called when the erasing operation is completed.
        - Parameter result: A `Result` enum indicating the outcome of the operation. If the operation is successful, the `Result` will contain `.success(Void)`. If the operation fails, it will contain `.failure(AnalyticsError)`.

     - Returns: Nothing.
     */
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
