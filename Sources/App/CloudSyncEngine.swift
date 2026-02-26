import CloudKit
import Foundation
import AppKit
import Security
import os.log

struct CloudTabRecord {
    let id: UUID
    var name: String
    var content: String
    var language: String
    var languageLocked: Bool
    var lastModified: Date
}

struct CloudClipboardRecord {
    let id: UUID
    var text: String
    var timestamp: Date
}

final class CloudSyncEngine: @unchecked Sendable {
    static let shared = CloudSyncEngine()

    enum RecordType: String {
        case scratchTab = "ScratchTab"
        case clipboardEntry = "ClipboardEntry"
    }

    private static let containerID = "iCloud.io.euforic.scratchpad"
    private static let zoneName = "ScratchpadData"

    /// Bump this to force a full re-sync (clears stale metadata and change tokens).
    private static let syncVersion = 2

    // Lazy CloudKit objects – only created when start() is called
    private var container: CKContainer?
    private var database: CKDatabase?
    private let zoneID = CKRecordZone.ID(zoneName: CloudSyncEngine.zoneName)

    private var syncEngine: CKSyncEngine?
    private let stateURL: URL
    private let metadataURL: URL
    private let manualSyncInterval: TimeInterval = 120
    private var manualSyncInFlight = false
    private var manualSyncQueued = false
    private var manualSyncTimer: Timer?
    private var manualSyncActivationObserver: NSObjectProtocol?

    // Cache of last-known server record data (system fields) per record ID, for conflict detection
    private var recordMetadata: [String: Data] = [:]

    /// True during first sync cycle – local tabs are authoritative and must not be overwritten.
    private(set) var isFirstSync = false

    private let logger = Logger(subsystem: "io.euforic.scratchpad", category: "CloudSync")

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let scratchpadDir = appSupport.appendingPathComponent("Scratchpad")
        try? FileManager.default.createDirectory(at: scratchpadDir, withIntermediateDirectories: true)
        stateURL = scratchpadDir.appendingPathComponent("cloud-sync-state.data")
        metadataURL = scratchpadDir.appendingPathComponent("cloud-record-metadata.json")

        loadRecordMetadata()
    }

    /// Call after app launch to start sync if the user has it enabled.
    func startIfEnabled() {
        if SettingsStore.shared.icloudSync {
            _ = start()
        }
    }

    // MARK: - Public API

    @discardableResult
    func start() -> Bool {
        guard Self.hasCloudKitEntitlement else {
            logger.error("Cloud sync unavailable: CloudKit entitlement missing.")
            return false
        }
        guard syncEngine == nil else { return true }

        guard let ckContainer = Self.defaultCloudContainer else { return false }

        container = ckContainer
        database = ckContainer.privateCloudDatabase

        guard let database else { return false }

        // Detect first sync: either no metadata, or sync version bumped (e.g. dev→prod migration).
        let storedVersion = UserDefaults.standard.integer(forKey: "cloudSyncVersion")
        let versionMismatch = storedVersion < Self.syncVersion
        let isFirstSync = recordMetadata.isEmpty || versionMismatch
        if isFirstSync {
            if versionMismatch {
                logger.info("Sync version bumped (\(storedVersion) → \(Self.syncVersion)) – clearing state for full re-sync")
                recordMetadata.removeAll()
                saveRecordMetadata()
                UserDefaults.standard.set(Self.syncVersion, forKey: "cloudSyncVersion")
            }
            try? FileManager.default.removeItem(at: stateURL)
        }

        // Set the instance flag BEFORE creating CKSyncEngine so no delegate
        // callback can observe it as false.
        if isFirstSync {
            self.isFirstSync = true
        }

        let stateSerialization = isFirstSync ? nil : loadStateSerialization()
        var configuration = CKSyncEngine.Configuration(
            database: database,
            stateSerialization: stateSerialization,
            delegate: self
        )
        configuration.automaticallySync = false
        syncEngine = CKSyncEngine(configuration)
        logger.info("CloudSyncEngine started (firstSync=\(self.isFirstSync), automaticSync=\(configuration.automaticallySync))")

        if isFirstSync {
            syncEngine?.state.add(pendingDatabaseChanges: [.saveZone(CKRecordZone(zoneID: zoneID))])
            reuploadAllRecords()
        }

        startManualSyncPipeline()

        return true
    }

    func stop() {
        syncEngine = nil
        stopManualSyncPipeline()
        recordMetadata.removeAll()
        saveRecordMetadata()
        logger.info("CloudSyncEngine stopped")
    }

    func recordChanged(_ id: UUID) {
        guard let engine = syncEngine else { return }
        let recordID = CKRecord.ID(recordName: id.uuidString, zoneID: zoneID)
        engine.state.add(pendingRecordZoneChanges: [.saveRecord(recordID)])
        triggerManualSync(reason: "local change")
    }

    func recordDeleted(_ id: UUID) {
        guard let engine = syncEngine else { return }
        let recordID = CKRecord.ID(recordName: id.uuidString, zoneID: zoneID)
        engine.state.add(pendingRecordZoneChanges: [.deleteRecord(recordID)])
        triggerManualSync(reason: "local delete")
    }

    // MARK: - State persistence

    private func loadStateSerialization() -> CKSyncEngine.State.Serialization? {
        guard let data = try? Data(contentsOf: stateURL) else { return nil }
        return try? JSONDecoder().decode(CKSyncEngine.State.Serialization.self, from: data)
    }

    private func saveStateSerialization(_ serialization: CKSyncEngine.State.Serialization) {
        do {
            let data = try JSONEncoder().encode(serialization)
            try data.write(to: stateURL, options: .atomic)
        } catch {
            logger.error("Failed to save sync state: \(error)")
        }
    }

    // MARK: - Record metadata cache

    private func loadRecordMetadata() {
        guard let data = try? Data(contentsOf: metadataURL),
              let decoded = try? JSONDecoder().decode([String: Data].self, from: data) else { return }
        recordMetadata = decoded
    }

    private func saveRecordMetadata() {
        guard let data = try? JSONEncoder().encode(recordMetadata) else { return }
        try? data.write(to: metadataURL, options: .atomic)
    }

    private func cacheRecordSystemFields(_ record: CKRecord) {
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: coder)
        coder.finishEncoding()
        recordMetadata[record.recordID.recordName] = coder.encodedData
        saveRecordMetadata()
    }

    private func cachedRecord(for recordID: CKRecord.ID, recordType: String) -> CKRecord {
        if let data = recordMetadata[recordID.recordName],
           let coder = try? NSKeyedUnarchiver(forReadingFrom: data) {
            coder.requiresSecureCoding = true
            if let record = CKRecord(coder: coder) {
                return record
            }
        }
        return CKRecord(recordType: recordType, recordID: recordID)
    }

    private func removeRecordMetadata(for recordID: CKRecord.ID) {
        recordMetadata.removeValue(forKey: recordID.recordName)
        saveRecordMetadata()
    }

    // MARK: - Record building

    private func buildScratchTabRecord(id: UUID, recordID: CKRecord.ID) -> CKRecord? {
        guard let tab = TabStore.shared.tabs.first(where: { $0.id == id && $0.fileURL == nil }) else { return nil }
        let record = cachedRecord(for: recordID, recordType: RecordType.scratchTab.rawValue)
        record["name"] = tab.name as CKRecordValue
        record["content"] = tab.content as CKRecordValue
        record["language"] = tab.language as CKRecordValue
        record["languageLocked"] = (tab.languageLocked ? 1 : 0) as CKRecordValue
        record["lastModified"] = tab.lastModified as CKRecordValue
        return record
    }

    private func buildClipboardEntryRecord(id: UUID, recordID: CKRecord.ID) -> CKRecord? {
        guard let entry = ClipboardStore.shared.entries.first(where: { $0.id == id && $0.kind == .text }) else { return nil }
        guard let text = entry.text else { return nil }
        let record = cachedRecord(for: recordID, recordType: RecordType.clipboardEntry.rawValue)
        record["text"] = text as CKRecordValue
        record["timestamp"] = entry.timestamp as CKRecordValue
        return record
    }

    // MARK: - Incoming changes

    private func applyFetchedChanges(_ event: CKSyncEngine.Event.FetchedRecordZoneChanges) {
        for modification in event.modifications {
            let record = modification.record
            cacheRecordSystemFields(record)

            switch record.recordType {
            case RecordType.scratchTab.rawValue:
                applyScratchTabRecord(record)
            case RecordType.clipboardEntry.rawValue:
                applyClipboardEntryRecord(record)
            default:
                logger.warning("Unknown record type: \(record.recordType)")
            }
        }

        for deletion in event.deletions {
            let id = deletion.recordID.recordName
            removeRecordMetadata(for: deletion.recordID)

            guard let uuid = UUID(uuidString: id) else { continue }

            switch deletion.recordType {
            case RecordType.scratchTab.rawValue:
                DispatchQueue.main.async {
                    TabStore.shared.removeCloudTab(id: uuid)
                }
            case RecordType.clipboardEntry.rawValue:
                DispatchQueue.main.async {
                    ClipboardStore.shared.removeCloudClipboardEntry(id: uuid)
                }
            default:
                break
            }
        }
    }

    private func startManualSyncPipeline() {
        stopManualSyncPipeline()

        manualSyncActivationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.triggerManualSync(reason: "app became active")
        }

        manualSyncTimer = Timer.scheduledTimer(
            withTimeInterval: manualSyncInterval,
            repeats: true
        ) { [weak self] _ in
            self?.triggerManualSync(reason: "periodic")
        }

        triggerManualSync(reason: "startup")
    }

    private func stopManualSyncPipeline() {
        if let observer = manualSyncActivationObserver {
            NotificationCenter.default.removeObserver(observer)
            manualSyncActivationObserver = nil
        }
        manualSyncTimer?.invalidate()
        manualSyncTimer = nil
        manualSyncInFlight = false
        manualSyncQueued = false
    }

    private func triggerManualSync(reason: String) {
        guard syncEngine != nil else { return }
        if manualSyncInFlight {
            manualSyncQueued = true
            logger.info("Manual sync queued while running: \(reason)")
            return
        }

        manualSyncInFlight = true
        let engine = syncEngine!
        logger.info("Starting manual sync: \(reason)")

        Task { [weak self] in
            if let self {
                do {
                    try await engine.sendChanges()
                } catch {
                    self.logger.error("Manual sendChanges failed: \(error.localizedDescription)")
                }

                do {
                    try await engine.fetchChanges()
                } catch {
                    self.logger.error("Manual fetchChanges failed: \(error.localizedDescription)")
                }

                self.manualSyncInFlight = false
                if self.manualSyncQueued {
                    self.manualSyncQueued = false
                    self.triggerManualSync(reason: "queued work")
                }
            }
        }
    }

    private func applyScratchTabRecord(_ record: CKRecord) {
        guard let name = record["name"] as? String,
              let content = record["content"] as? String,
              let language = record["language"] as? String,
              let lastModified = record["lastModified"] as? Date else {
            logger.error("Malformed ScratchTab record: \(record.recordID)")
            return
        }
        let languageLocked = (record["languageLocked"] as? Int64 ?? 0) != 0
        guard let uuid = UUID(uuidString: record.recordID.recordName) else { return }

        let tabRecord = CloudTabRecord(
            id: uuid,
            name: name,
            content: content,
            language: language,
            languageLocked: languageLocked,
            lastModified: lastModified
        )
        DispatchQueue.main.async {
            TabStore.shared.applyCloudTab(tabRecord)
        }
    }

    private func applyClipboardEntryRecord(_ record: CKRecord) {
        guard let text = record["text"] as? String,
              let timestamp = record["timestamp"] as? Date else {
            logger.error("Malformed ClipboardEntry record: \(record.recordID)")
            return
        }
        guard let uuid = UUID(uuidString: record.recordID.recordName) else { return }

        let clipboardRecord = CloudClipboardRecord(id: uuid, text: text, timestamp: timestamp)
        DispatchQueue.main.async {
            ClipboardStore.shared.applyCloudClipboardEntry(clipboardRecord)
        }
    }

    // MARK: - Conflict resolution

    private func resolveTabConflict(local record: CKRecord, server serverRecord: CKRecord) {
        let localModified = record["lastModified"] as? Date ?? .distantPast
        let serverModified = serverRecord["lastModified"] as? Date ?? .distantPast

        if localModified > serverModified {
            // Local wins: copy local fields onto server record and re-push
            serverRecord["name"] = record["name"]
            serverRecord["content"] = record["content"]
            serverRecord["language"] = record["language"]
            serverRecord["languageLocked"] = record["languageLocked"]
            serverRecord["lastModified"] = record["lastModified"]
            cacheRecordSystemFields(serverRecord)
        } else {
            // Server wins: accept server version
            cacheRecordSystemFields(serverRecord)
            applyScratchTabRecord(serverRecord)
        }
    }

    private func resolveClipboardConflict(local record: CKRecord, server serverRecord: CKRecord) {
        // Clipboard entries are append-only; server wins
        cacheRecordSystemFields(serverRecord)
        applyClipboardEntryRecord(serverRecord)
    }
}

// MARK: - CKSyncEngineDelegate

extension CloudSyncEngine: CKSyncEngineDelegate {

    func handleEvent(_ event: CKSyncEngine.Event, syncEngine: CKSyncEngine) async {
        switch event {
        case .stateUpdate(let stateUpdate):
            saveStateSerialization(stateUpdate.stateSerialization)

        case .accountChange(let accountChange):
            logger.info("Account change: \(String(describing: accountChange.changeType))")
            handleAccountChange(accountChange)

        case .fetchedDatabaseChanges(let event):
            handleFetchedDatabaseChanges(event)

        case .fetchedRecordZoneChanges(let event):
            logger.info("Fetched \(event.modifications.count) changes, \(event.deletions.count) deletions")
            applyFetchedChanges(event)

        case .sentRecordZoneChanges(let event):
            handleSentRecordZoneChanges(event)

        case .sentDatabaseChanges(let event):
            for failedZone in event.failedZoneSaves {
                logger.error("Failed zone save: code=\(failedZone.error.code.rawValue) \(failedZone.error.localizedDescription)")
            }

        case .didFetchChanges:
            DispatchQueue.main.async {
                TabStore.shared.lastICloudSync = Date()
            }

        case .didSendChanges:
            DispatchQueue.main.async {
                self.isFirstSync = false
                TabStore.shared.lastICloudSync = Date()
            }

        case .willFetchChanges, .willSendChanges,
             .willFetchRecordZoneChanges, .didFetchRecordZoneChanges:
            break

        @unknown default:
            break
        }
    }

    func nextRecordZoneChangeBatch(
        _ context: CKSyncEngine.SendChangesContext,
        syncEngine: CKSyncEngine
    ) async -> CKSyncEngine.RecordZoneChangeBatch? {
        let scope = context.options.scope
        let changes = syncEngine.state.pendingRecordZoneChanges.filter { scope.contains($0) }

        let batch = await CKSyncEngine.RecordZoneChangeBatch(pendingChanges: changes) { recordID in
            guard let uuid = UUID(uuidString: recordID.recordName) else { return nil }

            if let record = self.buildScratchTabRecord(id: uuid, recordID: recordID) {
                return record
            }
            if let record = self.buildClipboardEntryRecord(id: uuid, recordID: recordID) {
                return record
            }

            // Record no longer exists locally; remove from pending
            syncEngine.state.remove(pendingRecordZoneChanges: [.saveRecord(recordID)])
            return nil
        }
        return batch
    }

    // MARK: - Event handlers

    private func handleAccountChange(_ event: CKSyncEngine.Event.AccountChange) {
        switch event.changeType {
        case .signIn:
            syncEngine?.state.add(pendingDatabaseChanges: [.saveZone(CKRecordZone(zoneID: zoneID))])
            reuploadAllRecords()

        case .switchAccounts:
            clearLocalCloudState()

        case .signOut:
            clearLocalCloudState()

        @unknown default:
            break
        }
    }

    private func handleFetchedDatabaseChanges(_ event: CKSyncEngine.Event.FetchedDatabaseChanges) {
        for deletion in event.deletions {
            if deletion.zoneID == zoneID {
                clearLocalCloudState()
            }
        }
    }

    private func handleSentRecordZoneChanges(_ event: CKSyncEngine.Event.SentRecordZoneChanges) {
        var newPendingRecordZoneChanges = [CKSyncEngine.PendingRecordZoneChange]()
        var newPendingDatabaseChanges = [CKSyncEngine.PendingDatabaseChange]()

        for savedRecord in event.savedRecords {
            cacheRecordSystemFields(savedRecord)
        }

        for failedSave in event.failedRecordSaves {
            let failedRecord = failedSave.record
            logger.error("Failed to save \(failedRecord.recordType) \(failedRecord.recordID.recordName): code=\(failedSave.error.code.rawValue)")

            switch failedSave.error.code {
            case .serverRecordChanged:
                guard let serverRecord = failedSave.error.serverRecord else { continue }

                switch failedRecord.recordType {
                case RecordType.scratchTab.rawValue:
                    resolveTabConflict(local: failedRecord, server: serverRecord)
                case RecordType.clipboardEntry.rawValue:
                    resolveClipboardConflict(local: failedRecord, server: serverRecord)
                default:
                    break
                }
                newPendingRecordZoneChanges.append(.saveRecord(failedRecord.recordID))

            case .zoneNotFound:
                let zone = CKRecordZone(zoneID: failedRecord.recordID.zoneID)
                newPendingDatabaseChanges.append(.saveZone(zone))
                newPendingRecordZoneChanges.append(.saveRecord(failedRecord.recordID))
                removeRecordMetadata(for: failedRecord.recordID)

            case .unknownItem:
                newPendingRecordZoneChanges.append(.saveRecord(failedRecord.recordID))
                removeRecordMetadata(for: failedRecord.recordID)

            case .networkFailure, .networkUnavailable, .zoneBusy, .serviceUnavailable,
                 .notAuthenticated, .operationCancelled:
                break

            default:
                logger.error("Unhandled save error: \(failedSave.error)")
            }
        }

        if !newPendingDatabaseChanges.isEmpty {
            syncEngine?.state.add(pendingDatabaseChanges: newPendingDatabaseChanges)
        }
        if !newPendingRecordZoneChanges.isEmpty {
            syncEngine?.state.add(pendingRecordZoneChanges: newPendingRecordZoneChanges)
        }
    }

    // MARK: - Helpers

    private func reuploadAllRecords() {
        let tabChanges: [CKSyncEngine.PendingRecordZoneChange] = TabStore.shared.tabs
            .filter { $0.fileURL == nil }
            .map { .saveRecord(CKRecord.ID(recordName: $0.id.uuidString, zoneID: zoneID)) }

        let clipboardChanges: [CKSyncEngine.PendingRecordZoneChange] = ClipboardStore.shared.entries
            .filter { $0.kind == .text }
            .map { .saveRecord(CKRecord.ID(recordName: $0.id.uuidString, zoneID: zoneID)) }

        logger.info("Re-uploading \(tabChanges.count) tabs, \(clipboardChanges.count) clipboard entries")
        syncEngine?.state.add(pendingRecordZoneChanges: tabChanges + clipboardChanges)
    }

    private func clearLocalCloudState() {
        recordMetadata.removeAll()
        saveRecordMetadata()
        try? FileManager.default.removeItem(at: stateURL)
    }

    private static let hasCloudKitEntitlement: Bool = CloudSyncEngine.isCloudKitEntitled()

    private static func isCloudKitEntitled() -> Bool {
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else { return false }
        guard let task = SecTaskCreateFromSelf(nil) else { return false }

        let entitlementValue = SecTaskCopyValueForEntitlement(task, "com.apple.developer.icloud-container-identifiers" as CFString, nil)
        if let containers = entitlementValue as? [String] {
            return containers.contains(Self.containerID)
        }
        if let container = entitlementValue as? String {
            return container == Self.containerID
        }
        if let containers = entitlementValue as? NSArray {
            for case let container as String in containers where container == Self.containerID {
                return true
            }
        }
        if let container = entitlementValue as? NSString {
            return container as String == Self.containerID
        }

        return false
    }

    private static var defaultCloudContainer: CKContainer? {
        guard hasCloudKitEntitlement else { return nil }
        return CKContainer(identifier: containerID)
    }
}
