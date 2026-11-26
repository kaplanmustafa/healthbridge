import Foundation
import SwiftUI

@MainActor
final class ExportViewModel: ObservableObject {
    @Published var selected = HealthMetric.suggested { didSet { invalidatePreview() } }
    @Published var startDate = Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date() { didSet { invalidatePreview() } }
    @Published var endDate = Date() { didSet { invalidatePreview() } }
    @Published var format: ExportFormat = .json
    @Published private(set) var export: HealthExport?
    @Published private(set) var busy = false
    @Published private(set) var progress: Double = 0
    @Published var alert: String?
    @Published var sharedFile: SharedFile?
    @Published var endpoint: String = UserDefaults.standard.string(forKey: "healthbridge.endpoint") ?? "" {
        didSet {
            if oldValue != endpoint {
                consent = false
                // Never reuse a saved credential for a changed destination.
                token = ""
                apiStatus = nil
            }
        }
    }
    @Published var token = "" { didSet { if oldValue != token { consent = false } } }
    @Published var consent = false
    @Published private(set) var apiStatus: String?
    @Published private(set) var permissionRequested = false

    private let service = HealthKitService()
    private let api = APIClient()

    init() {
        do { token = try TokenVault.load(endpoint: endpoint) } catch { alert = error.localizedDescription }
    }

    struct SharedFile: Identifiable {
        let url: URL
        var id: URL { url }
    }

    var recordCount: Int { export?.records.count ?? 0 }
    var ready: Bool { export != nil && recordCount > 0 && !busy }

    func selectAll(in group: MetricGroup) {
        let types = Set(HealthMetric.allCases.filter { $0.group == group })
        if types.isSubset(of: selected) { selected.subtract(types) }
        else { selected.formUnion(types) }
    }

    func setRange(days: Int) {
        endDate = Date()
        startDate = Calendar.current.date(byAdding: .day, value: 1 - days, to: endDate) ?? endDate
    }

    func invalidatePreview() {
        export = nil
        consent = false
        apiStatus = nil
    }

    func prepare() async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        invalidatePreview()
        progress = 0
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        guard let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate)),
              start < end else { alert = HealthBridgeError.invalidRange.localizedDescription; return }
        let metrics = selected
        do {
            try await service.requestReadAccess(to: metrics)
            permissionRequested = true
            let result = try await service.read(metrics: metrics, start: start, endExclusive: end) { [weak self] done, total in
                self?.progress = Double(done) / Double(total)
            }
            export = result
            if result.records.isEmpty { alert = HealthBridgeError.noRecords.localizedDescription }
        } catch {
            alert = error.localizedDescription
        }
    }

    func makeShareFile() {
        guard ready, let export else { return }
        do { sharedFile = SharedFile(url: try ExportService.makeFile(export, format: format)) }
        catch { alert = error.localizedDescription }
    }

    func saveConnection() {
        do {
            let verified = try EndpointValidator.url(from: endpoint)
            try TokenVault.save(token, endpoint: verified.absoluteString)
            UserDefaults.standard.set(verified.absoluteString, forKey: "healthbridge.endpoint")
            alert = "Bağlantı ayarları kaydedildi. Henüz hiçbir sağlık kaydı gönderilmedi."
        } catch { alert = error.localizedDescription }
    }

    func clearConnection() {
        endpoint = ""
        token = ""
        consent = false
        apiStatus = nil
        UserDefaults.standard.removeObject(forKey: "healthbridge.endpoint")
        do { try TokenVault.delete() } catch { alert = error.localizedDescription }
    }

    func send() async {
        guard ready, let export else { return }
        busy = true
        apiStatus = nil
        defer { busy = false; consent = false }
        do {
            let status = try await api.send(export, endpoint: endpoint, token: token, consent: consent)
            apiStatus = "Sunucu aktarımı kabul etti • HTTP \(status) • \(export.records.count) kayıt"
        } catch { alert = error.localizedDescription }
    }
}
