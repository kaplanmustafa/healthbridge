import Foundation
import HealthKit

final class HealthKitService {
    private let store = HKHealthStore()
    static let maxRecords = 100_000

    func requestReadAccess(to metrics: Set<HealthMetric>) async throws {
        guard HKHealthStore.isHealthDataAvailable() else { throw HealthBridgeError.unavailable }
        guard !metrics.isEmpty else { throw HealthBridgeError.emptySelection }
        var types: Set<HKObjectType> = []
        for metric in metrics {
            guard let type = metric.sampleType else { throw HealthBridgeError.unsupportedMetric(metric.title) }
            types.insert(type)
        }
        // Read only. No HealthKit write authorization is requested.
        try await store.requestAuthorization(toShare: [], read: types)
    }

    func read(metrics: Set<HealthMetric>, start: Date, endExclusive: Date,
              progress: @escaping @MainActor (Int, Int) -> Void) async throws -> HealthExport {
        guard HKHealthStore.isHealthDataAvailable() else { throw HealthBridgeError.unavailable }
        guard start < endExclusive else { throw HealthBridgeError.invalidRange }
        guard !metrics.isEmpty else { throw HealthBridgeError.emptySelection }

        let ordered = HealthMetric.allCases.filter { metrics.contains($0) }
        // No strict date flags: include records overlapping the selected interval,
        // such as a sleep record that starts before midnight.
        let predicate = HKQuery.predicateForSamples(withStart: start, end: endExclusive, options: [])
        var records: [HealthRecord] = []
        for (index, metric) in ordered.enumerated() {
            try Task.checkCancellation()
            guard let type = metric.sampleType else { throw HealthBridgeError.unsupportedMetric(metric.title) }
            let remaining = Self.maxRecords - records.count
            let samples = try await query(type: type, predicate: predicate, limit: remaining + 1)
            guard samples.count <= remaining else { throw HealthBridgeError.tooManyRecords }
            for sample in samples {
                // Half-open interval [start, endExclusive); preserve records that overlap it.
                let point = sample.startDate == sample.endDate
                guard sample.startDate < endExclusive &&
                    (point ? sample.startDate >= start : sample.endDate > start) else { continue }
                guard let record = makeRecord(sample, metric: metric) else {
                    throw HealthBridgeError.unsupportedMetric(metric.title)
                }
                records.append(record)
            }
            await progress(index + 1, ordered.count)
        }

        records.sort {
            if $0.startDate == $1.startDate { return $0.id.uuidString < $1.id.uuidString }
            return $0.startDate < $1.startDate
        }
        return HealthExport(schemaVersion: 1, exportedAt: Date(), rangeStart: start,
                            rangeEndExclusive: endExclusive, selectedMetrics: ordered.map(\.rawValue),
                            timeZone: TimeZone.current.identifier, records: records)
    }

    private func query(type: HKSampleType, predicate: NSPredicate, limit: Int) async throws -> [HKSample] {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: limit,
                                      sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) {
                _, samples, error in
                if let error { continuation.resume(throwing: error) }
                else { continuation.resume(returning: samples ?? []) }
            }
            store.execute(query)
        }
    }

    private func makeRecord(_ sample: HKSample, metric: HealthMetric) -> HealthRecord? {
        var value: Double?
        var unit: String?
        var category: String?
        var code: UInt?
        var workoutDuration: Double?

        if let quantity = sample as? HKQuantitySample, let measurement = metric.measurement {
            let numeric = quantity.quantity.doubleValue(for: measurement.unit) * measurement.multiplier
            value = numeric.isFinite ? numeric : nil
            unit = measurement.label
        } else if let sleep = sample as? HKCategorySample, metric == .sleep {
            code = UInt(exactly: sleep.value)
            switch HKCategoryValueSleepAnalysis(rawValue: sleep.value) {
            case .inBed: category = "inBed"
            case .asleepUnspecified: category = "asleepUnspecified"
            case .awake: category = "awake"
            case .asleepCore: category = "asleepCore"
            case .asleepDeep: category = "asleepDeep"
            case .asleepREM: category = "asleepREM"
            default: category = "unknown"
            }
            value = sleep.endDate.timeIntervalSince(sleep.startDate) / 60
            unit = "min"
        } else if let workout = sample as? HKWorkout, metric == .workouts {
            code = workout.workoutActivityType.rawValue
            category = "workout"
            workoutDuration = workout.duration
            value = workout.duration / 60
            unit = "min"
        } else {
            return nil
        }

        return HealthRecord(id: sample.uuid, metric: metric.rawValue, startDate: sample.startDate,
                            endDate: sample.endDate, value: value, unit: unit, category: category,
                            categoryCode: code, sourceName: sample.sourceRevision.source.name,
                            sourceBundleIdentifier: sample.sourceRevision.source.bundleIdentifier,
                            workoutDurationSeconds: workoutDuration)
    }
}
