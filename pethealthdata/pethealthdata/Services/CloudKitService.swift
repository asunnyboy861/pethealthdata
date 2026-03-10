import CloudKit
import Foundation

/// CloudKit service for cross-device data synchronization
final class CloudKitService {
    static let shared = CloudKitService()
    
    private let container: CKContainer
    private let database: CKDatabase
    
    private init() {
        self.container = CKContainer(identifier: "iCloud.com.zzoutuo.pethealthdata")
        self.database = container.privateCloudDatabase
    }
    
    // MARK: - CloudKit Status
    
    /// Check if CloudKit is available by checking account status
    func isCloudKitAvailable() async -> Bool {
        do {
            let status = try await container.accountStatus()
            return status != .noAccount && status != .restricted
        } catch {
            return false
        }
    }
    
    /// Get current user's iCloud account status
    func getUserAccountStatus(completion: @escaping (CKAccountStatus) -> Void) {
        container.accountStatus { status, error in
            DispatchQueue.main.async {
                completion(status)
            }
        }
    }
    
    // MARK: - Record Operations
    
    /// Save a record to CloudKit
    func saveRecord(_ record: CKRecord, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        database.save(record) { savedRecord, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let record = savedRecord {
                    completion(.success(record))
                }
            }
        }
    }
    
    /// Fetch a record by ID
    func fetchRecord(withID recordID: CKRecord.ID, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        database.fetch(withRecordID: recordID) { record, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let record = record {
                    completion(.success(record))
                }
            }
        }
    }
    
    /// Delete a record by ID
    func deleteRecord(withID recordID: CKRecord.ID, completion: @escaping (Result<Void, Error>) -> Void) {
        database.delete(withRecordID: recordID) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    /// Query records by record type using CKQuery
    func queryRecords(recordType: String, completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let records = records {
                    completion(.success(records))
                }
            }
        }
    }
    
    // MARK: - Subscription Operations
    
    /// Create a subscription for record changes
    func createSubscription(forRecordType recordType: String, subscriptionID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let subscription = CKDatabaseSubscription(subscriptionID: subscriptionID)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        database.save(subscription) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    // MARK: - Zone Operations
    
    /// Create a custom record zone
    func createRecordZone(zoneID: CKRecordZone.ID, completion: @escaping (Result<CKRecordZone, Error>) -> Void) {
        let zone = CKRecordZone(zoneID: zoneID)
        database.save(zone) { savedZone, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let zone = savedZone {
                    completion(.success(zone))
                }
            }
        }
    }
}
