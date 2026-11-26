import Foundation

enum ExportService {
    static func json(_ export: HealthExport) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(formatter.string(from: date))
        }
        return try encoder.encode(export)
    }

    static func csv(_ export: HealthExport) -> Data {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let columns = ["id", "metric", "startDate", "endDate", "value", "unit", "category",
                       "categoryCode", "sourceName", "sourceBundleIdentifier", "workoutDurationSeconds"]
        var lines = [columns.joined(separator: ",")]
        lines.reserveCapacity(export.records.count + 1)
        for record in export.records {
            let fields = [
                record.id.uuidString, record.metric, formatter.string(from: record.startDate),
                formatter.string(from: record.endDate), record.value.map { String($0) } ?? "",
                record.unit ?? "", record.category ?? "", record.categoryCode.map { String($0) } ?? "",
                safeSpreadsheetText(record.sourceName), safeSpreadsheetText(record.sourceBundleIdentifier),
                record.workoutDurationSeconds.map { String($0) } ?? ""
            ]
            lines.append(fields.map(csvField).joined(separator: ","))
        }
        // UTF-8 BOM improves Turkish text compatibility with spreadsheet applications.
        return Data(("\u{FEFF}" + lines.joined(separator: "\r\n") + "\r\n").utf8)
    }

    static func csvField(_ value: String) -> String {
        "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    static func safeSpreadsheetText(_ text: String) -> String {
        // Defend against formula injection from externally supplied source metadata.
        if text.first.map({ "=+-@\t\r\n".contains($0) }) == true { return "'" + text }
        if let first = text.trimmingCharacters(in: .whitespacesAndNewlines).first,
           "=+-@".contains(first) { return "'" + text }
        return text
    }

    static func makeFile(_ export: HealthExport, format: ExportFormat) throws -> URL {
        guard !export.records.isEmpty else { throw HealthBridgeError.noRecords }
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("HealthBridgeExports", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true,
                                                attributes: [.protectionKey: FileProtectionType.complete])
        let filename = "healthbridge-\(UUID().uuidString.prefix(8)).\(format.fileExtension)"
        let file = directory.appendingPathComponent(filename)
        let data = format == .json ? try json(export) : csv(export)
        try data.write(to: file, options: [.atomic, .completeFileProtection])
        return file
    }

    static func removeFile(_ url: URL) { try? FileManager.default.removeItem(at: url) }

    static func clearTemporaryExports() {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("HealthBridgeExports", isDirectory: true)
        try? FileManager.default.removeItem(at: directory)
    }
}
