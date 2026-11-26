import Foundation
import HealthKit

enum MetricGroup: String, CaseIterable, Identifiable {
    case activity = "Aktivite"
    case heart = "Kalp ve solunum"
    case sleep = "Uyku"
    case body = "Vücut"
    case nutrition = "Beslenme"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .activity: return "figure.walk"
        case .heart: return "heart.fill"
        case .sleep: return "moon.stars.fill"
        case .body: return "scalemass.fill"
        case .nutrition: return "fork.knife"
        }
    }
}

enum HealthMetric: String, CaseIterable, Identifiable, Hashable {
    case steps, walkingRunningDistance, cyclingDistance, activeEnergy, basalEnergy, exerciseTime, flightsClimbed, workouts
    case heartRate, restingHeartRate, walkingHeartRate, hrv, oxygenSaturation, respiratoryRate, systolicPressure, diastolicPressure, vo2Max
    case sleep
    case weight, bodyFat, bmi, leanBodyMass, height, waist, bodyTemperature, bloodGlucose
    case dietaryEnergy, protein, carbohydrates, fat, water

    var id: String { rawValue }
    var group: MetricGroup {
        switch self {
        case .steps, .walkingRunningDistance, .cyclingDistance, .activeEnergy, .basalEnergy, .exerciseTime, .flightsClimbed, .workouts: return .activity
        case .heartRate, .restingHeartRate, .walkingHeartRate, .hrv, .oxygenSaturation, .respiratoryRate, .systolicPressure, .diastolicPressure, .vo2Max: return .heart
        case .sleep: return .sleep
        case .weight, .bodyFat, .bmi, .leanBodyMass, .height, .waist, .bodyTemperature, .bloodGlucose: return .body
        case .dietaryEnergy, .protein, .carbohydrates, .fat, .water: return .nutrition
        }
    }
    var title: String {
        switch self {
        case .steps: return "Adım"
        case .walkingRunningDistance: return "Yürüyüş ve koşu mesafesi"
        case .cyclingDistance: return "Bisiklet mesafesi"
        case .activeEnergy: return "Aktif enerji"
        case .basalEnergy: return "Dinlenme enerjisi"
        case .exerciseTime: return "Egzersiz süresi"
        case .flightsClimbed: return "Çıkılan kat"
        case .workouts: return "Antrenman"
        case .heartRate: return "Nabız"
        case .restingHeartRate: return "Dinlenik nabız"
        case .walkingHeartRate: return "Yürüyüş nabız ortalaması"
        case .hrv: return "Kalp hızı değişkenliği (HRV)"
        case .oxygenSaturation: return "Kandaki oksijen (SpO₂)"
        case .respiratoryRate: return "Solunum hızı"
        case .systolicPressure: return "Sistolik tansiyon"
        case .diastolicPressure: return "Diyastolik tansiyon"
        case .vo2Max: return "Kardiyo fitness (VO₂ maks)"
        case .bloodGlucose: return "Kan şekeri"
        case .sleep: return "Uyku ve evreleri"
        case .weight: return "Kilo"
        case .bodyFat: return "Yağ oranı"
        case .bmi: return "Vücut kitle indeksi"
        case .leanBodyMass: return "Yağsız vücut kütlesi"
        case .height: return "Boy"
        case .waist: return "Bel çevresi"
        case .bodyTemperature: return "Vücut sıcaklığı"
        case .dietaryEnergy: return "Alınan enerji"
        case .protein: return "Protein"
        case .carbohydrates: return "Karbonhidrat"
        case .fat: return "Yağ"
        case .water: return "Su"
        }
    }
    var quantityIdentifier: HKQuantityTypeIdentifier? {
        switch self {
        case .steps: return .stepCount
        case .walkingRunningDistance: return .distanceWalkingRunning
        case .cyclingDistance: return .distanceCycling
        case .activeEnergy: return .activeEnergyBurned
        case .basalEnergy: return .basalEnergyBurned
        case .exerciseTime: return .appleExerciseTime
        case .flightsClimbed: return .flightsClimbed
        case .heartRate: return .heartRate
        case .restingHeartRate: return .restingHeartRate
        case .walkingHeartRate: return .walkingHeartRateAverage
        case .hrv: return .heartRateVariabilitySDNN
        case .oxygenSaturation: return .oxygenSaturation
        case .respiratoryRate: return .respiratoryRate
        case .systolicPressure: return .bloodPressureSystolic
        case .diastolicPressure: return .bloodPressureDiastolic
        case .vo2Max: return .vo2Max
        case .bloodGlucose: return .bloodGlucose
        case .weight: return .bodyMass
        case .bodyFat: return .bodyFatPercentage
        case .bmi: return .bodyMassIndex
        case .leanBodyMass: return .leanBodyMass
        case .height: return .height
        case .waist: return .waistCircumference
        case .bodyTemperature: return .bodyTemperature
        case .dietaryEnergy: return .dietaryEnergyConsumed
        case .protein: return .dietaryProtein
        case .carbohydrates: return .dietaryCarbohydrates
        case .fat: return .dietaryFatTotal
        case .water: return .dietaryWater
        case .sleep, .workouts: return nil
        }
    }
    var sampleType: HKSampleType? {
        if let identifier = quantityIdentifier { return HKObjectType.quantityType(forIdentifier: identifier) }
        switch self {
        case .sleep: return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        case .workouts: return HKObjectType.workoutType()
        default: return nil
        }
    }
    var measurement: (unit: HKUnit, label: String, multiplier: Double)? {
        switch self {
        case .steps, .flightsClimbed: return (.count(), "count", 1)
        case .bmi: return (.count(), "kg/m²", 1)
        case .walkingRunningDistance, .cyclingDistance: return (.meterUnit(with: .kilo), "km", 1)
        case .activeEnergy, .basalEnergy, .dietaryEnergy: return (.kilocalorie(), "kcal", 1)
        case .exerciseTime: return (.minute(), "min", 1)
        case .heartRate, .restingHeartRate, .walkingHeartRate: return (.count().unitDivided(by: .minute()), "bpm", 1)
        case .respiratoryRate: return (.count().unitDivided(by: .minute()), "breaths/min", 1)
        case .systolicPressure, .diastolicPressure: return (.millimeterOfMercury(), "mmHg", 1)
        case .vo2Max: return (.literUnit(with: .milli).unitDivided(by: .gramUnit(with: .kilo)).unitDivided(by: .minute()), "mL/kg/min", 1)
        case .bloodGlucose: return (.gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci)), "mg/dL", 1)
        case .hrv: return (.secondUnit(with: .milli), "ms", 1)
        case .oxygenSaturation, .bodyFat: return (.percent(), "%", 100)
        case .weight, .leanBodyMass: return (.gramUnit(with: .kilo), "kg", 1)
        case .height, .waist: return (.meterUnit(with: .centi), "cm", 1)
        case .bodyTemperature: return (.degreeCelsius(), "°C", 1)
        case .protein, .carbohydrates, .fat: return (.gram(), "g", 1)
        case .water: return (.literUnit(with: .milli), "mL", 1)
        case .sleep, .workouts: return nil
        }
    }
    static let suggested: Set<Self> = [.steps, .activeEnergy, .heartRate, .restingHeartRate, .sleep, .weight, .bodyFat, .workouts]
}
