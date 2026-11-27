import Foundation
import HealthKit
import CoreLocation

final class HealthKitService {
    private let store = HKHealthStore()
    static let maxRecords = 100_000
    static let maxSeriesPoints = 200_000

    func requestReadAccess(to metrics: Set<HealthMetric>) async throws {
        guard HKHealthStore.isHealthDataAvailable() else { throw HealthBridgeError.unavailable }
        guard !metrics.isEmpty else { throw HealthBridgeError.emptySelection }
        var types: Set<HKObjectType> = []
        for metric in metrics {
            guard let type = metric.sampleType else { throw HealthBridgeError.unsupportedMetric(metric.title) }
            types.insert(type)
        }
        // Reading routes requires read permission for workouts as well.
        if metrics.contains(.workoutRoutes) { types.insert(HKObjectType.workoutType()) }
        // Read only. No HealthKit write authorization is requested.
        try await store.requestAuthorization(toShare: [], read: types)
    }

    func read(metrics: Set<HealthMetric>, start: Date, endExclusive: Date,
              progress: @escaping @MainActor (Int, Int) -> Void) async throws -> HealthExport {
        guard HKHealthStore.isHealthDataAvailable() else { throw HealthBridgeError.unavailable }
        guard start < endExclusive else { throw HealthBridgeError.invalidRange }
        guard !metrics.isEmpty else { throw HealthBridgeError.emptySelection }

        let ordered = HealthMetric.allCases.filter { metrics.contains($0) }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: endExclusive, options: [])
        var records: [HealthRecord] = []
        var issues: [String: String] = [:]
        var pointCount = 0
        for (index, metric) in ordered.enumerated() {
            try Task.checkCancellation()
            // Commit a type only when all its samples have been read successfully.
            do {
                guard let type = metric.sampleType else { throw HealthBridgeError.unsupportedMetric(metric.title) }
                let remaining = Self.maxRecords - records.count
                let samples = try await query(type: type, predicate: predicate, limit: remaining + 1)
                guard samples.count <= remaining else { throw HealthBridgeError.tooManyRecords }
                var batch: [HealthRecord] = []
                var batchPoints = 0
                for sample in samples {
                    try Task.checkCancellation()
                    let point = sample.startDate == sample.endDate
                    guard sample.startDate < endExclusive &&
                        (point ? sample.startDate >= start : sample.endDate > start) else { continue }
                    let record = try await makeRecord(sample, metric: metric,
                                                      pointBudget: Self.maxSeriesPoints - pointCount - batchPoints)
                    batch.append(record)
                    batchPoints += record.details?.points?.count ?? 0
                }
                records.append(contentsOf: batch)
                pointCount += batchPoints
            } catch HealthBridgeError.tooManyRecords {
                throw HealthBridgeError.tooManyRecords
            } catch HealthBridgeError.tooManySeriesPoints {
                throw HealthBridgeError.tooManySeriesPoints
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                // HealthKit may hide denied read access as an empty result. Actual query failures
                // are reported separately, not mistaken for zero measurements.
                issues[metric.rawValue] = "Okunamadı. Sağlık izinlerini ve cihaz desteğini kontrol et."
            }
            await progress(index + 1, ordered.count)
        }

        records.sort {
            if $0.startDate == $1.startDate { return $0.id.uuidString < $1.id.uuidString }
            return $0.startDate < $1.startDate
        }
        return HealthExport(schemaVersion: 2, exportedAt: Date(), rangeStart: start,
                            rangeEndExclusive: endExclusive, selectedMetrics: ordered.map(\.rawValue),
                            timeZone: TimeZone.current.identifier, records: records,
                            readIssues: issues.isEmpty ? nil : issues)
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

    private func number(_ quantity: HKQuantity?, unit: HKUnit, multiplier: Double = 1) -> Double? {
        guard let quantity, quantity.is(compatibleWith: unit) else { return nil }
        let value = quantity.doubleValue(for: unit) * multiplier
        return value.isFinite ? value : nil
    }

    private func makeRecord(_ sample: HKSample, metric: HealthMetric, pointBudget: Int) async throws -> HealthRecord {
        var value: Double?
        var unit: String?
        var category: String?
        var code: UInt?
        var workoutDuration: Double?
        var details: RecordDetails?

        if let quantity = sample as? HKQuantitySample, let measurement = metric.measurement {
            if let numeric = number(quantity.quantity, unit: measurement.unit, multiplier: measurement.multiplier) {
                value = numeric
                unit = measurement.label
            } else if metric == .appleSleepingBreathingDisturbances,
                      let numeric = number(quantity.quantity, unit: .count().unitDivided(by: .hour())) {
                value = numeric
                unit = "count/h"
            } else {
                throw HealthBridgeError.incompatibleUnit(metric.title)
            }
        } else if let event = sample as? HKCategorySample {
            code = UInt(exactly: event.value)
            category = "category"
            // Preserve all raw codes; duration is not a severity score.
            if metric == .sleep {
                switch HKCategoryValueSleepAnalysis(rawValue: event.value) {
                case .inBed: category = "inBed"
                case .asleepUnspecified: category = "asleepUnspecified"
                case .awake: category = "awake"
                case .asleepCore: category = "asleepCore"
                case .asleepDeep: category = "asleepDeep"
                case .asleepREM: category = "asleepREM"
                default: category = "unknown"
                }
                value = event.endDate.timeIntervalSince(event.startDate) / 60
                unit = "min"
            } else {
                value = Double(event.value)
                unit = "categoryCode"
                if metric == .mindfulSession || metric == .toothbrushingEvent || metric == .handwashingEvent {
                    value = event.endDate.timeIntervalSince(event.startDate)
                    unit = "s"
                }
            }
        } else if let workout = sample as? HKWorkout, metric == .workouts {
            code = workout.workoutActivityType.rawValue
            category = "workout"
            workoutDuration = workout.duration
            value = workout.duration / 60
            unit = "min"
            var measurements: [String: Double] = [:]
            measurements["totalEnergyKcal"] = number(workout.totalEnergyBurned, unit: .kilocalorie())
            measurements["totalDistanceMeters"] = number(workout.totalDistance, unit: .meter())
            measurements["totalSwimmingStrokes"] = number(workout.totalSwimmingStrokeCount, unit: .count())
            measurements["totalFlightsClimbed"] = number(workout.totalFlightsClimbed, unit: .count())
            details = RecordDetails(measurements: measurements)
        } else if let route = sample as? HKWorkoutRoute, metric == .workoutRoutes {
            var points: [SeriesPoint] = []
            for try await location in HKWorkoutRouteQueryDescriptor(route).results(for: store) {
                try Task.checkCancellation()
                guard points.count < pointBudget else { throw HealthBridgeError.tooManySeriesPoints }
                points.append(SeriesPoint(offsetSeconds: location.timestamp.timeIntervalSince(sample.startDate),
                                          latitude: finite(location.coordinate.latitude), longitude: finite(location.coordinate.longitude),
                                          altitudeMeters: finite(location.altitude),
                                          horizontalAccuracyMeters: finite(location.horizontalAccuracy),
                                          verticalAccuracyMeters: finite(location.verticalAccuracy),
                                          speedMetersPerSecond: finite(location.speed),
                                          courseDegrees: finite(location.course)))
            }
            value = Double(points.count)
            unit = "count"
            category = "gpsRoute"
            details = RecordDetails(points: points)
        } else if let heartbeat = sample as? HKHeartbeatSeriesSample, metric == .heartbeatSeries {
            var points: [SeriesPoint] = []
            for try await beat in HKHeartbeatSeriesQueryDescriptor(heartbeat).results(for: store) {
                try Task.checkCancellation()
                guard points.count < pointBudget else { throw HealthBridgeError.tooManySeriesPoints }
                points.append(SeriesPoint(offsetSeconds: beat.timeIntervalSinceStart, precededByGap: beat.precededByGap))
            }
            value = Double(points.count)
            unit = "count"
            category = "heartbeatSeries"
            details = RecordDetails(points: points)
        } else if let ecg = sample as? HKElectrocardiogram, metric == .electrocardiograms {
            var points: [SeriesPoint] = []
            for try await measurement in HKElectrocardiogramQueryDescriptor(ecg).results(for: store) {
                try Task.checkCancellation()
                guard points.count < pointBudget else { throw HealthBridgeError.tooManySeriesPoints }
                points.append(SeriesPoint(offsetSeconds: measurement.timeSinceSampleStart,
                                          microvolts: number(measurement.quantity(for: .appleWatchSimilarToLeadI), unit: .voltUnit(with: .micro))))
            }
            code = UInt(exactly: ecg.classification.rawValue)
            category = "electrocardiogram"
            value = number(ecg.averageHeartRate, unit: .count().unitDivided(by: .minute()))
            unit = "bpm"
            var measurements: [String: Double] = [:]
            measurements["samplingFrequencyHz"] = number(ecg.samplingFrequency, unit: .hertz())
            details = RecordDetails(measurements: measurements,
                                    codes: ["classification": Int(ecg.classification.rawValue), "symptomsStatus": Int(ecg.symptomsStatus.rawValue)],
                                    points: points)
        } else if let audiogram = sample as? HKAudiogramSample, metric == .audiograms {
            guard audiogram.sensitivityPoints.count <= pointBudget else { throw HealthBridgeError.tooManySeriesPoints }
            let points = audiogram.sensitivityPoints.map { point in
                SeriesPoint(offsetSeconds: 0, frequencyHz: number(point.frequency, unit: .hertz()),
                            leftEarDecibelsHL: number(point.leftEarSensitivity, unit: .decibelHearingLevel()),
                            rightEarDecibelsHL: number(point.rightEarSensitivity, unit: .decibelHearingLevel()))
            }
            value = Double(points.count)
            unit = "count"
            category = "audiogram"
            details = RecordDetails(points: points)
        } else if #available(iOS 18.0, *), let mood = sample as? HKStateOfMind, metric == .stateOfMind {
            value = finite(mood.valence)
            unit = "valence"
            category = "stateOfMind"
            code = UInt(exactly: mood.kind.rawValue)
            details = RecordDetails(codes: ["kind": Int(mood.kind.rawValue), "valenceClassification": Int(mood.valenceClassification.rawValue)],
                                    codeLists: ["labels": mood.labels.map { Int($0.rawValue) }, "associations": mood.associations.map { Int($0.rawValue) }])
        } else {
            throw HealthBridgeError.unsupportedMetric(metric.title)
        }

        return HealthRecord(id: sample.uuid, metric: metric.rawValue, startDate: sample.startDate,
                            endDate: sample.endDate, value: value, unit: unit, category: category,
                            categoryCode: code, sourceName: sample.sourceRevision.source.name,
                            sourceBundleIdentifier: sample.sourceRevision.source.bundleIdentifier,
                            workoutDurationSeconds: workoutDuration, details: details)
    }

    private func finite(_ value: Double) -> Double? { value.isFinite ? value : nil }
}
