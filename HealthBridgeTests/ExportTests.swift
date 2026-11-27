import XCTest
import HealthKit
@testable import HealthBridge

final class ExportTests: XCTestCase {
    private func fixture(source: String = "Kaynak, \"A\"") -> HealthExport {
        let start = Date(timeIntervalSince1970: 1_700_000_000.125)
        let record = HealthRecord(id: UUID(), metric: "steps", startDate: start,
                                  endDate: start.addingTimeInterval(60), value: 123, unit: "count",
                                  category: nil, categoryCode: nil, sourceName: source,
                                  sourceBundleIdentifier: "example.device", workoutDurationSeconds: nil)
        return HealthExport(schemaVersion: 1, exportedAt: start, rangeStart: start,
                            rangeEndExclusive: start.addingTimeInterval(86400),
                            selectedMetrics: ["steps"], timeZone: "Europe/Istanbul", records: [record])
    }

    func testJSONSchemaAndRecords() throws {
        let export = fixture()
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: ExportService.json(export)) as? [String: Any])
        XCTAssertEqual(json["schemaVersion"] as? Int, 1)
        XCTAssertEqual(json["timeZone"] as? String, "Europe/Istanbul")
        let records = try XCTUnwrap(json["records"] as? [[String: Any]])
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?["value"] as? Double, 123)
        XCTAssertTrue((records.first?["startDate"] as? String)?.contains(".125Z") == true)
        XCTAssertEqual(export.counts["steps"], 1)
    }

    func testCSVQuotingAndBOM() throws {
        let csv = try ExportService.csv(fixture())
        XCTAssertEqual(Array(csv.prefix(3)), [0xEF, 0xBB, 0xBF])
        let text = try XCTUnwrap(String(data: csv, encoding: .utf8))
        XCTAssertTrue(text.contains("\"Kaynak, \"\"A\"\"\""))
        XCTAssertTrue(text.contains("\"123.0\",\"count\""))
    }

    func testSpreadsheetSourceFormulaProtection() throws {
        let csv = try ExportService.csv(fixture(source: "=HYPERLINK(1)"))
        let text = try XCTUnwrap(String(data: csv, encoding: .utf8))
        XCTAssertTrue(text.contains("\"'=HYPERLINK(1)\""))
        XCTAssertEqual(ExportService.safeSpreadsheetText("  +1"), "'  +1")
    }

    func testEndpointsMustBeHTTPSWithoutEmbeddedCredentialsOrQueries() {
        XCTAssertNoThrow(try EndpointValidator.url(from: "https://example.org/health"))
        for address in ["http://example.org/health", "ftp://example.org", "https://", "https://a:b@example.org", "https://example.org/path?secret=1", "https://example.org/path#part"] {
            XCTAssertThrowsError(try EndpointValidator.url(from: address), address)
        }
    }

    func testConsentRequiredBeforeNetworking() async throws {
        do {
            _ = try await APIClient().send(fixture(), endpoint: "https://example.org", token: "", consent: false)
            XCTFail("Missing consent must prevent sending")
        } catch HealthBridgeError.missingConsent {}
        catch { XCTFail("Unexpected error: \(error)") }
    }

    func testPercentConversion() throws {
        let measurement = try XCTUnwrap(HealthMetric.bodyFat.measurement)
        let quantity = HKQuantity(unit: .percent(), doubleValue: 0.246)
        XCTAssertEqual(quantity.doubleValue(for: measurement.unit) * measurement.multiplier, 24.6, accuracy: 0.00001)
    }

    func testMetricIdentifiersAreUnique() {
        XCTAssertEqual(Set(HealthMetric.allCases.map(\.rawValue)).count, HealthMetric.allCases.count)
    }
    func testExpandedCatalog() throws {
        XCTAssertEqual(HealthMetric.allCases.count, 192)
        XCTAssertTrue(Set(HealthMetric.available).isSuperset(of: HealthMetric.suggested))
        XCTAssertTrue(HealthMetric.available.contains(.runningSpeed))
        XCTAssertTrue(HealthMetric.available.contains(.dietaryVitaminD))
        XCTAssertTrue(HealthMetric.available.contains(.headache))
        XCTAssertTrue(HealthMetric.available.contains(.electrocardiograms))
        XCTAssertTrue(HealthMetric.available.contains(.workoutRoutes))
        XCTAssertTrue(HealthMetric.available.contains(.audiograms))
        var identifiers: Set<String> = []
        for metric in HealthMetric.available {
            let type = try XCTUnwrap(metric.sampleType)
            XCTAssertTrue(identifiers.insert(type.identifier).inserted, metric.rawValue)
            if let quantity = type as? HKQuantityType {
                let measurement = try XCTUnwrap(metric.measurement, metric.rawValue)
                if metric == .appleSleepingBreathingDisturbances {
                    XCTAssertTrue(quantity.is(compatibleWith: measurement.unit) ||
                                  quantity.is(compatibleWith: .count().unitDivided(by: .hour())), metric.rawValue)
                } else {
                    XCTAssertTrue(quantity.is(compatibleWith: measurement.unit), metric.rawValue)
                }
            }
        }
    }

    func testV2StructuredSeriesAndReadIssues() throws {
        let original = fixture()
        var record = original.records[0]
        record.details = RecordDetails(codes: ["classification": 1],
                                       points: [SeriesPoint(offsetSeconds: 0.25, microvolts: 12.5)])
        let export = HealthExport(schemaVersion: 2, exportedAt: original.exportedAt,
                                  rangeStart: original.rangeStart, rangeEndExclusive: original.rangeEndExclusive,
                                  selectedMetrics: ["steps", "electrocardiograms"], timeZone: original.timeZone,
                                  records: [record], readIssues: ["electrocardiograms": "Okunamadı"])
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: ExportService.json(export)) as? [String: Any])
        XCTAssertEqual(json["schemaVersion"] as? Int, 2)
        XCTAssertNotNil(json["readIssues"])
        let rows = try XCTUnwrap(json["records"] as? [[String: Any]])
        let details = try XCTUnwrap(rows[0]["details"] as? [String: Any])
        let points = try XCTUnwrap(details["points"] as? [[String: Any]])
        XCTAssertEqual(points[0]["microvolts"] as? Double, 12.5)
        let csv = String(decoding: try ExportService.csv(export), as: UTF8.self)
        XCTAssertTrue(csv.contains("detailsJSON"))
        XCTAssertTrue(csv.contains("microvolts"))
    }

    func testCSVDoesNotSilentlyLoseUnencodableDetails() throws {
        let original = fixture()
        var record = original.records[0]
        record.details = RecordDetails(points: [SeriesPoint(offsetSeconds: .nan)])
        let export = HealthExport(schemaVersion: 2, exportedAt: original.exportedAt,
                                  rangeStart: original.rangeStart, rangeEndExclusive: original.rangeEndExclusive,
                                  selectedMetrics: ["steps"], timeZone: original.timeZone, records: [record])
        XCTAssertThrowsError(try ExportService.csv(export))
        XCTAssertThrowsError(try ExportService.json(export))
    }
}
