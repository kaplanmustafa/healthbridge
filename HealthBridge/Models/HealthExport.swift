import Foundation

struct HealthRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let metric: String
    let startDate: Date
    let endDate: Date
    let value: Double?
    let unit: String?
    let category: String?
    let categoryCode: UInt?
    let sourceName: String
    let sourceBundleIdentifier: String
    let workoutDurationSeconds: Double?
}

struct HealthExport: Codable, Equatable {
    let schemaVersion: Int
    let exportedAt: Date
    let rangeStart: Date
    let rangeEndExclusive: Date
    let selectedMetrics: [String]
    let timeZone: String
    let records: [HealthRecord]

    var counts: [String: Int] {
        records.reduce(into: [:]) { $0[$1.metric, default: 0] += 1 }
    }
}

enum ExportFormat: String, CaseIterable, Identifiable {
    case json = "JSON"
    case csv = "CSV"

    var id: String { rawValue }
    var fileExtension: String { rawValue.lowercased() }
    var detail: String {
        switch self {
        case .json: return "API'ler ve yapılandırılmış veri"
        case .csv: return "Excel, Numbers ve tablolar"
        }
    }
}

enum HealthBridgeError: LocalizedError {
    case unavailable
    case invalidRange
    case emptySelection
    case noRecords
    case tooManyRecords
    case unsupportedMetric(String)
    case invalidEndpoint
    case invalidToken
    case missingConsent
    case invalidResponse
    case httpError(Int)
    case keychainFailure(Int32)

    var errorDescription: String? {
        switch self {
        case .unavailable: return "Apple Sağlık bu cihazda kullanılamıyor."
        case .invalidRange: return "Başlangıç tarihi bitiş tarihinden sonra olamaz."
        case .emptySelection: return "En az bir veri türü seç."
        case .noRecords: return "Aktarılabilecek kayıt bulunamadı. Tarih aralığını ve Sağlık izinlerini kontrol et."
        case .tooManyRecords: return "100.000 kayıt sınırı aşıldı. Tarih aralığını veya veri türlerini azaltıp tekrar dene; hiçbir kayıt sessizce atlanmadı."
        case .unsupportedMetric(let name): return "\(name) bu cihazda okunamıyor."
        case .invalidEndpoint: return "Geçerli bir HTTPS API adresi gir. Adreste kullanıcı adı, parola, sorgu veya parça (#) bulunmamalı."
        case .invalidToken: return "Erişim anahtarı geçersiz karakterler içeriyor."
        case .missingConsent: return "Gönderimden önce hedef hizmeti ve paylaşım iznini onayla."
        case .invalidResponse: return "Sunucudan geçerli bir HTTP yanıtı alınamadı."
        case .httpError(let code): return "Aktarım tamamlanamadı. Sunucu HTTP \(code) yanıtı verdi."
        case .keychainFailure(let code): return "Erişim anahtarı güvenli alanda işlenemedi (\(code))."
        }
    }
}
