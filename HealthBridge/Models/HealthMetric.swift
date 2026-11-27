import Foundation
import HealthKit

enum MetricGroup: String, CaseIterable, Identifiable {
    case activity = "Aktivite"
    case heart = "Kalp ve solunum"
    case sleep = "Uyku"
    case body = "Vücut"
    case nutrition = "Beslenme"
    case mobility = "Hareketlilik"
    case hearing = "İşitme"
    case lab = "Testler ve ölçümler"
    case environment = "Çevre ve dalış"
    case mind = "Ruh hali ve farkındalık"
    case care = "Kişisel bakım"
    case reproductive = "Üreme sağlığı"
    case symptoms = "Belirtiler"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .activity: return "figure.walk"
        case .heart: return "heart.fill"
        case .sleep: return "moon.stars.fill"
        case .body: return "scalemass.fill"
        case .nutrition: return "fork.knife"
        case .mobility: return "figure.walk.motion"
        case .hearing: return "ear"
        case .lab: return "cross.case"
        case .environment: return "sun.max"
        case .mind: return "brain.head.profile"
        case .care: return "hand.raised"
        case .reproductive: return "heart.text.square"
        case .symptoms: return "waveform.path.ecg"
        }
    }
}

enum HealthMetric: String, CaseIterable, Identifiable, Hashable {
    case steps, walkingRunningDistance, cyclingDistance, activeEnergy, basalEnergy, exerciseTime, flightsClimbed, workouts
    case heartRate, restingHeartRate, walkingHeartRate, hrv, oxygenSaturation, respiratoryRate, systolicPressure, diastolicPressure, vo2Max
    case sleep
    case weight, bodyFat, bmi, leanBodyMass, height, waist, bodyTemperature, bloodGlucose
    case dietaryEnergy, protein, carbohydrates, fat, water
    case runningGroundContactTime, runningPower, runningSpeed, runningStrideLength, runningVerticalOscillation
    case pushCount, distanceWheelchair, swimmingStrokeCount, distanceSwimming, distanceDownhillSnowSports
    case nikeFuel, appleMoveTime, appleStandTime, cyclingCadence, cyclingFunctionalThresholdPower
    case cyclingPower, cyclingSpeed, physicalEffort, distanceCrossCountrySkiing, crossCountrySkiingSpeed
    case distancePaddleSports, distanceRowing, distanceSkatingSports, paddleSportsSpeed, rowingSpeed
    case estimatedWorkoutEffortScore, workoutEffortScore, basalBodyTemperature, appleSleepingWristTemperature, appleSleepingBreathingDisturbances
    case environmentalAudioExposure, environmentalSoundReduction, headphoneAudioExposure, heartRateRecoveryOneMinute, atrialFibrillationBurden
    case electrodermalActivity, forcedExpiratoryVolume1, forcedVitalCapacity, inhalerUsage, insulinDelivery
    case numberOfTimesFallen, peakExpiratoryFlowRate, peripheralPerfusionIndex, appleWalkingSteadiness, sixMinuteWalkTestDistance
    case walkingSpeed, walkingStepLength, walkingAsymmetryPercentage, walkingDoubleSupportPercentage, stairAscentSpeed
    case stairDescentSpeed, timeInDaylight, uvExposure, underwaterDepth, waterTemperature
    case bloodAlcoholContent, numberOfAlcoholicBeverages, dietaryBiotin, dietaryCaffeine, dietaryCalcium
    case dietaryChloride, dietaryCholesterol, dietaryChromium, dietaryCopper, dietaryFatMonounsaturated
    case dietaryFatPolyunsaturated, dietaryFatSaturated, dietaryFiber, dietaryFolate, dietaryIodine
    case dietaryIron, dietaryMagnesium, dietaryManganese, dietaryMolybdenum, dietaryNiacin
    case dietaryPantothenicAcid, dietaryPhosphorus, dietaryPotassium, dietaryRiboflavin, dietarySelenium
    case dietarySodium, dietarySugar, dietaryThiamin, dietaryVitaminA, dietaryVitaminB12
    case dietaryVitaminB6, dietaryVitaminC, dietaryVitaminD, dietaryVitaminE, dietaryVitaminK
    case dietaryZinc, appleStandHour, lowCardioFitnessEvent, lowHeartRateEvent, highHeartRateEvent
    case irregularHeartRhythmEvent, hypertensionEvent, appleWalkingSteadinessEvent, environmentalAudioExposureEvent, headphoneAudioExposureEvent
    case mindfulSession, toothbrushingEvent, handwashingEvent, menstrualFlow
    case intermenstrualBleeding, infrequentMenstrualCycles, irregularMenstrualCycles, persistentIntermenstrualBleeding, prolongedMenstrualPeriods
    case cervicalMucusQuality, ovulationTestResult, progesteroneTestResult, sexualActivity, contraceptive
    case pregnancy, pregnancyTestResult, lactation, abdominalCramps, bloating
    case constipation, diarrhea, heartburn, nausea, vomiting
    case appetiteChanges, chills, dizziness, fainting, fatigue
    case fever, generalizedBodyAche, hotFlashes, chestTightnessOrPain, coughing
    case rapidPoundingOrFlutteringHeartbeat, shortnessOfBreath, skippedHeartbeat, wheezing, lowerBackPain
    case headache, memoryLapse, moodChanges, lossOfSmell, lossOfTaste
    case runnyNose, soreThroat, sinusCongestion, breastPain, pelvicPain
    case vaginalDryness, acne, drySkin, hairLoss, nightSweats
    case sleepChanges, bladderIncontinence, electrocardiograms, heartbeatSeries, workoutRoutes
    case audiograms, stateOfMind

    var id: String { rawValue }
    var group: MetricGroup {
        switch self {
        case .steps, .walkingRunningDistance, .cyclingDistance, .activeEnergy, .basalEnergy, .exerciseTime, .flightsClimbed, .workouts: return .activity
        case .heartRate, .restingHeartRate, .walkingHeartRate, .hrv, .oxygenSaturation, .respiratoryRate, .systolicPressure, .diastolicPressure, .vo2Max: return .heart
        case .sleep: return .sleep
        case .weight, .bodyFat, .bmi, .leanBodyMass, .height, .waist, .bodyTemperature, .bloodGlucose: return .body
        case .dietaryEnergy, .protein, .carbohydrates, .fat, .water: return .nutrition

        case .runningGroundContactTime, .runningPower, .runningSpeed, .runningStrideLength, .runningVerticalOscillation, .pushCount, .distanceWheelchair, .swimmingStrokeCount, .distanceSwimming, .distanceDownhillSnowSports, .nikeFuel, .appleMoveTime, .appleStandTime, .cyclingCadence, .cyclingFunctionalThresholdPower, .cyclingPower, .cyclingSpeed, .physicalEffort, .distanceCrossCountrySkiing, .crossCountrySkiingSpeed, .distancePaddleSports, .distanceRowing, .distanceSkatingSports, .paddleSportsSpeed, .rowingSpeed, .estimatedWorkoutEffortScore, .workoutEffortScore, .appleStandHour, .workoutRoutes: return .activity
        case .basalBodyTemperature: return .body
        case .appleSleepingWristTemperature, .appleSleepingBreathingDisturbances: return .sleep
        case .environmentalAudioExposure, .environmentalSoundReduction, .headphoneAudioExposure, .environmentalAudioExposureEvent, .headphoneAudioExposureEvent, .audiograms: return .hearing
        case .heartRateRecoveryOneMinute, .atrialFibrillationBurden, .lowCardioFitnessEvent, .lowHeartRateEvent, .highHeartRateEvent, .irregularHeartRhythmEvent, .hypertensionEvent, .electrocardiograms, .heartbeatSeries: return .heart
        case .electrodermalActivity, .forcedExpiratoryVolume1, .forcedVitalCapacity, .inhalerUsage, .insulinDelivery, .numberOfTimesFallen, .peakExpiratoryFlowRate, .peripheralPerfusionIndex: return .lab
        case .appleWalkingSteadiness, .sixMinuteWalkTestDistance, .walkingSpeed, .walkingStepLength, .walkingAsymmetryPercentage, .walkingDoubleSupportPercentage, .stairAscentSpeed, .stairDescentSpeed, .appleWalkingSteadinessEvent: return .mobility
        case .timeInDaylight, .uvExposure, .underwaterDepth, .waterTemperature: return .environment
        case .bloodAlcoholContent, .numberOfAlcoholicBeverages, .dietaryBiotin, .dietaryCaffeine, .dietaryCalcium, .dietaryChloride, .dietaryCholesterol, .dietaryChromium, .dietaryCopper, .dietaryFatMonounsaturated, .dietaryFatPolyunsaturated, .dietaryFatSaturated, .dietaryFiber, .dietaryFolate, .dietaryIodine, .dietaryIron, .dietaryMagnesium, .dietaryManganese, .dietaryMolybdenum, .dietaryNiacin, .dietaryPantothenicAcid, .dietaryPhosphorus, .dietaryPotassium, .dietaryRiboflavin, .dietarySelenium, .dietarySodium, .dietarySugar, .dietaryThiamin, .dietaryVitaminA, .dietaryVitaminB12, .dietaryVitaminB6, .dietaryVitaminC, .dietaryVitaminD, .dietaryVitaminE, .dietaryVitaminK, .dietaryZinc: return .nutrition
        case .mindfulSession, .stateOfMind: return .mind
        case .toothbrushingEvent, .handwashingEvent: return .care
        case .menstrualFlow, .intermenstrualBleeding, .infrequentMenstrualCycles, .irregularMenstrualCycles, .persistentIntermenstrualBleeding, .prolongedMenstrualPeriods, .cervicalMucusQuality, .ovulationTestResult, .progesteroneTestResult, .sexualActivity, .contraceptive, .pregnancy, .pregnancyTestResult, .lactation: return .reproductive
        case .abdominalCramps, .bloating, .constipation, .diarrhea, .heartburn, .nausea, .vomiting, .appetiteChanges, .chills, .dizziness, .fainting, .fatigue, .fever, .generalizedBodyAche, .hotFlashes, .chestTightnessOrPain, .coughing, .rapidPoundingOrFlutteringHeartbeat, .shortnessOfBreath, .skippedHeartbeat, .wheezing, .lowerBackPain, .headache, .memoryLapse, .moodChanges, .lossOfSmell, .lossOfTaste, .runnyNose, .soreThroat, .sinusCongestion, .breastPain, .pelvicPain, .vaginalDryness, .acne, .drySkin, .hairLoss, .nightSweats, .sleepChanges, .bladderIncontinence: return .symptoms
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

        case .runningGroundContactTime: return "Koşu yer temas süresi"
        case .runningPower: return "Koşu gücü"
        case .runningSpeed: return "Koşu hızı"
        case .runningStrideLength: return "Koşu adım uzunluğu"
        case .runningVerticalOscillation: return "Koşu dikey salınımı"
        case .pushCount: return "Tekerlekli sandalye itiş sayısı"
        case .distanceWheelchair: return "Tekerlekli sandalye mesafesi"
        case .swimmingStrokeCount: return "Yüzme kulaç sayısı"
        case .distanceSwimming: return "Yüzme mesafesi"
        case .distanceDownhillSnowSports: return "Kayak ve snowboard mesafesi"
        case .nikeFuel: return "NikeFuel"
        case .appleMoveTime: return "Hareket süresi"
        case .appleStandTime: return "Ayakta kalma süresi"
        case .cyclingCadence: return "Bisiklet kadansı"
        case .cyclingFunctionalThresholdPower: return "Bisiklet işlevsel eşik gücü"
        case .cyclingPower: return "Bisiklet gücü"
        case .cyclingSpeed: return "Bisiklet hızı"
        case .physicalEffort: return "Fiziksel efor"
        case .distanceCrossCountrySkiing: return "Kros kayak mesafesi"
        case .crossCountrySkiingSpeed: return "Kros kayak hızı"
        case .distancePaddleSports: return "Kürek sporları mesafesi"
        case .distanceRowing: return "Kürek çekme mesafesi"
        case .distanceSkatingSports: return "Paten mesafesi"
        case .paddleSportsSpeed: return "Kürek sporları hızı"
        case .rowingSpeed: return "Kürek çekme hızı"
        case .estimatedWorkoutEffortScore: return "Tahmini antrenman eforu"
        case .workoutEffortScore: return "Antrenman eforu"
        case .basalBodyTemperature: return "Bazal vücut sıcaklığı"
        case .appleSleepingWristTemperature: return "Uykuda bilek sıcaklığı"
        case .appleSleepingBreathingDisturbances: return "Uykuda solunum kesintileri"
        case .environmentalAudioExposure: return "Ortam ses seviyesi"
        case .environmentalSoundReduction: return "Ortam sesi azaltma"
        case .headphoneAudioExposure: return "Kulaklık ses seviyesi"
        case .heartRateRecoveryOneMinute: return "Bir dakikalık nabız toparlanması"
        case .atrialFibrillationBurden: return "Atriyal fibrilasyon yükü"
        case .electrodermalActivity: return "Elektrodermal aktivite"
        case .forcedExpiratoryVolume1: return "Birinci saniye zorlu ekspirasyon hacmi"
        case .forcedVitalCapacity: return "Zorlu vital kapasite"
        case .inhalerUsage: return "İnhaler kullanımı"
        case .insulinDelivery: return "İnsülin dozu"
        case .numberOfTimesFallen: return "Düşme sayısı"
        case .peakExpiratoryFlowRate: return "Tepe ekspirasyon akımı"
        case .peripheralPerfusionIndex: return "Periferik perfüzyon indeksi"
        case .appleWalkingSteadiness: return "Yürüme dengesi"
        case .sixMinuteWalkTestDistance: return "Altı dakika yürüme testi"
        case .walkingSpeed: return "Yürüme hızı"
        case .walkingStepLength: return "Yürüyüş adım uzunluğu"
        case .walkingAsymmetryPercentage: return "Yürüyüş asimetrisi"
        case .walkingDoubleSupportPercentage: return "Çift ayak destek oranı"
        case .stairAscentSpeed: return "Merdiven çıkma hızı"
        case .stairDescentSpeed: return "Merdiven inme hızı"
        case .timeInDaylight: return "Gün ışığında geçirilen süre"
        case .uvExposure: return "UV maruziyeti"
        case .underwaterDepth: return "Su altı derinliği"
        case .waterTemperature: return "Su sıcaklığı"
        case .bloodAlcoholContent: return "Kan alkol oranı"
        case .numberOfAlcoholicBeverages: return "Alkollü içecek sayısı"
        case .dietaryBiotin: return "Biyotin (B7)"
        case .dietaryCaffeine: return "Kafein"
        case .dietaryCalcium: return "Kalsiyum"
        case .dietaryChloride: return "Klorür"
        case .dietaryCholesterol: return "Kolesterol"
        case .dietaryChromium: return "Krom"
        case .dietaryCopper: return "Bakır"
        case .dietaryFatMonounsaturated: return "Tekli doymamış yağ"
        case .dietaryFatPolyunsaturated: return "Çoklu doymamış yağ"
        case .dietaryFatSaturated: return "Doymuş yağ"
        case .dietaryFiber: return "Lif"
        case .dietaryFolate: return "Folat (B9)"
        case .dietaryIodine: return "İyot"
        case .dietaryIron: return "Demir"
        case .dietaryMagnesium: return "Magnezyum"
        case .dietaryManganese: return "Manganez"
        case .dietaryMolybdenum: return "Molibden"
        case .dietaryNiacin: return "Niasin (B3)"
        case .dietaryPantothenicAcid: return "Pantotenik asit (B5)"
        case .dietaryPhosphorus: return "Fosfor"
        case .dietaryPotassium: return "Potasyum"
        case .dietaryRiboflavin: return "Riboflavin (B2)"
        case .dietarySelenium: return "Selenyum"
        case .dietarySodium: return "Sodyum"
        case .dietarySugar: return "Şeker"
        case .dietaryThiamin: return "Tiamin (B1)"
        case .dietaryVitaminA: return "A vitamini"
        case .dietaryVitaminB12: return "B12 vitamini"
        case .dietaryVitaminB6: return "B6 vitamini"
        case .dietaryVitaminC: return "C vitamini"
        case .dietaryVitaminD: return "D vitamini"
        case .dietaryVitaminE: return "E vitamini"
        case .dietaryVitaminK: return "K vitamini"
        case .dietaryZinc: return "Çinko"
        case .appleStandHour: return "Ayakta kalınan saat"
        case .lowCardioFitnessEvent: return "Düşük kardiyo fitness bildirimi"
        case .lowHeartRateEvent: return "Düşük nabız bildirimi"
        case .highHeartRateEvent: return "Yüksek nabız bildirimi"
        case .irregularHeartRhythmEvent: return "Düzensiz ritim bildirimi"
        case .hypertensionEvent: return "Hipertansiyon bildirimi"
        case .appleWalkingSteadinessEvent: return "Yürüme dengesi bildirimi"
        case .environmentalAudioExposureEvent: return "Ortam gürültü bildirimi"
        case .headphoneAudioExposureEvent: return "Kulaklık ses bildirimi"
        case .mindfulSession: return "Farkındalık oturumu"
        case .toothbrushingEvent: return "Diş fırçalama"
        case .handwashingEvent: return "El yıkama"
        case .menstrualFlow: return "Adet akışı"
        case .intermenstrualBleeding: return "Ara kanama"
        case .infrequentMenstrualCycles: return "Seyrek adet döngüsü"
        case .irregularMenstrualCycles: return "Düzensiz adet döngüsü"
        case .persistentIntermenstrualBleeding: return "Sürekli ara kanama"
        case .prolongedMenstrualPeriods: return "Uzun adet dönemi"
        case .cervicalMucusQuality: return "Servikal mukus kalitesi"
        case .ovulationTestResult: return "Ovülasyon testi"
        case .progesteroneTestResult: return "Progesteron testi"
        case .sexualActivity: return "Cinsel aktivite"
        case .contraceptive: return "Doğum kontrolü"
        case .pregnancy: return "Gebelik"
        case .pregnancyTestResult: return "Gebelik testi"
        case .lactation: return "Emzirme"
        case .abdominalCramps: return "Karın krampları"
        case .bloating: return "Şişkinlik"
        case .constipation: return "Kabızlık"
        case .diarrhea: return "İshal"
        case .heartburn: return "Mide yanması"
        case .nausea: return "Bulantı"
        case .vomiting: return "Kusma"
        case .appetiteChanges: return "İştah değişimleri"
        case .chills: return "Titreme"
        case .dizziness: return "Baş dönmesi"
        case .fainting: return "Bayılma"
        case .fatigue: return "Yorgunluk"
        case .fever: return "Ateş"
        case .generalizedBodyAche: return "Genel vücut ağrısı"
        case .hotFlashes: return "Sıcak basması"
        case .chestTightnessOrPain: return "Göğüste sıkışma veya ağrı"
        case .coughing: return "Öksürük"
        case .rapidPoundingOrFlutteringHeartbeat: return "Çarpıntı"
        case .shortnessOfBreath: return "Nefes darlığı"
        case .skippedHeartbeat: return "Kalp atımı atlama"
        case .wheezing: return "Hırıltılı solunum"
        case .lowerBackPain: return "Bel ağrısı"
        case .headache: return "Baş ağrısı"
        case .memoryLapse: return "Hafıza kaybı"
        case .moodChanges: return "Ruh hali değişimleri"
        case .lossOfSmell: return "Koku kaybı"
        case .lossOfTaste: return "Tat kaybı"
        case .runnyNose: return "Burun akıntısı"
        case .soreThroat: return "Boğaz ağrısı"
        case .sinusCongestion: return "Sinüs tıkanıklığı"
        case .breastPain: return "Meme ağrısı"
        case .pelvicPain: return "Pelvik ağrı"
        case .vaginalDryness: return "Vajinal kuruluk"
        case .acne: return "Akne"
        case .drySkin: return "Cilt kuruluğu"
        case .hairLoss: return "Saç dökülmesi"
        case .nightSweats: return "Gece terlemeleri"
        case .sleepChanges: return "Uyku değişimleri"
        case .bladderIncontinence: return "İdrar kaçırma"
        case .electrocardiograms: return "EKG ve voltaj ölçümleri"
        case .heartbeatSeries: return "Kalp atımı zaman serisi"
        case .workoutRoutes: return "Antrenman GPS rotaları"
        case .audiograms: return "İşitme testleri (odyogram)"
        case .stateOfMind: return "Ruh hali kayıtları"
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
        case .runningGroundContactTime: return .runningGroundContactTime
        case .runningPower: return .runningPower
        case .runningSpeed: return .runningSpeed
        case .runningStrideLength: return .runningStrideLength
        case .runningVerticalOscillation: return .runningVerticalOscillation
        case .pushCount: return .pushCount
        case .distanceWheelchair: return .distanceWheelchair
        case .swimmingStrokeCount: return .swimmingStrokeCount
        case .distanceSwimming: return .distanceSwimming
        case .distanceDownhillSnowSports: return .distanceDownhillSnowSports
        case .nikeFuel: return .nikeFuel
        case .appleMoveTime: return .appleMoveTime
        case .appleStandTime: return .appleStandTime
        case .cyclingCadence: return .cyclingCadence
        case .cyclingFunctionalThresholdPower: return .cyclingFunctionalThresholdPower
        case .cyclingPower: return .cyclingPower
        case .cyclingSpeed: return .cyclingSpeed
        case .physicalEffort: return .physicalEffort
        case .distanceCrossCountrySkiing:
            if #available(iOS 18.0, *) { return .distanceCrossCountrySkiing }
            return nil
        case .crossCountrySkiingSpeed:
            if #available(iOS 18.0, *) { return .crossCountrySkiingSpeed }
            return nil
        case .distancePaddleSports:
            if #available(iOS 18.0, *) { return .distancePaddleSports }
            return nil
        case .distanceRowing:
            if #available(iOS 18.0, *) { return .distanceRowing }
            return nil
        case .distanceSkatingSports:
            if #available(iOS 18.0, *) { return .distanceSkatingSports }
            return nil
        case .paddleSportsSpeed:
            if #available(iOS 18.0, *) { return .paddleSportsSpeed }
            return nil
        case .rowingSpeed:
            if #available(iOS 18.0, *) { return .rowingSpeed }
            return nil
        case .estimatedWorkoutEffortScore:
            if #available(iOS 18.0, *) { return .estimatedWorkoutEffortScore }
            return nil
        case .workoutEffortScore:
            if #available(iOS 18.0, *) { return .workoutEffortScore }
            return nil
        case .basalBodyTemperature: return .basalBodyTemperature
        case .appleSleepingWristTemperature: return .appleSleepingWristTemperature
        case .appleSleepingBreathingDisturbances:
            if #available(iOS 18.0, *) { return .appleSleepingBreathingDisturbances }
            return nil
        case .environmentalAudioExposure: return .environmentalAudioExposure
        case .environmentalSoundReduction: return .environmentalSoundReduction
        case .headphoneAudioExposure: return .headphoneAudioExposure
        case .heartRateRecoveryOneMinute: return .heartRateRecoveryOneMinute
        case .atrialFibrillationBurden: return .atrialFibrillationBurden
        case .electrodermalActivity: return .electrodermalActivity
        case .forcedExpiratoryVolume1: return .forcedExpiratoryVolume1
        case .forcedVitalCapacity: return .forcedVitalCapacity
        case .inhalerUsage: return .inhalerUsage
        case .insulinDelivery: return .insulinDelivery
        case .numberOfTimesFallen: return .numberOfTimesFallen
        case .peakExpiratoryFlowRate: return .peakExpiratoryFlowRate
        case .peripheralPerfusionIndex: return .peripheralPerfusionIndex
        case .appleWalkingSteadiness: return .appleWalkingSteadiness
        case .sixMinuteWalkTestDistance: return .sixMinuteWalkTestDistance
        case .walkingSpeed: return .walkingSpeed
        case .walkingStepLength: return .walkingStepLength
        case .walkingAsymmetryPercentage: return .walkingAsymmetryPercentage
        case .walkingDoubleSupportPercentage: return .walkingDoubleSupportPercentage
        case .stairAscentSpeed: return .stairAscentSpeed
        case .stairDescentSpeed: return .stairDescentSpeed
        case .timeInDaylight: return .timeInDaylight
        case .uvExposure: return .uvExposure
        case .underwaterDepth: return .underwaterDepth
        case .waterTemperature: return .waterTemperature
        case .bloodAlcoholContent: return .bloodAlcoholContent
        case .numberOfAlcoholicBeverages: return .numberOfAlcoholicBeverages
        case .dietaryBiotin: return .dietaryBiotin
        case .dietaryCaffeine: return .dietaryCaffeine
        case .dietaryCalcium: return .dietaryCalcium
        case .dietaryChloride: return .dietaryChloride
        case .dietaryCholesterol: return .dietaryCholesterol
        case .dietaryChromium: return .dietaryChromium
        case .dietaryCopper: return .dietaryCopper
        case .dietaryFatMonounsaturated: return .dietaryFatMonounsaturated
        case .dietaryFatPolyunsaturated: return .dietaryFatPolyunsaturated
        case .dietaryFatSaturated: return .dietaryFatSaturated
        case .dietaryFiber: return .dietaryFiber
        case .dietaryFolate: return .dietaryFolate
        case .dietaryIodine: return .dietaryIodine
        case .dietaryIron: return .dietaryIron
        case .dietaryMagnesium: return .dietaryMagnesium
        case .dietaryManganese: return .dietaryManganese
        case .dietaryMolybdenum: return .dietaryMolybdenum
        case .dietaryNiacin: return .dietaryNiacin
        case .dietaryPantothenicAcid: return .dietaryPantothenicAcid
        case .dietaryPhosphorus: return .dietaryPhosphorus
        case .dietaryPotassium: return .dietaryPotassium
        case .dietaryRiboflavin: return .dietaryRiboflavin
        case .dietarySelenium: return .dietarySelenium
        case .dietarySodium: return .dietarySodium
        case .dietarySugar: return .dietarySugar
        case .dietaryThiamin: return .dietaryThiamin
        case .dietaryVitaminA: return .dietaryVitaminA
        case .dietaryVitaminB12: return .dietaryVitaminB12
        case .dietaryVitaminB6: return .dietaryVitaminB6
        case .dietaryVitaminC: return .dietaryVitaminC
        case .dietaryVitaminD: return .dietaryVitaminD
        case .dietaryVitaminE: return .dietaryVitaminE
        case .dietaryVitaminK: return .dietaryVitaminK
        case .dietaryZinc: return .dietaryZinc
        default: return nil
        }
    }
    var categoryIdentifier: HKCategoryTypeIdentifier? {
        switch self {
        case .sleep: return .sleepAnalysis
        case .appleStandHour: return .appleStandHour
        case .lowCardioFitnessEvent: return .lowCardioFitnessEvent
        case .lowHeartRateEvent: return .lowHeartRateEvent
        case .highHeartRateEvent: return .highHeartRateEvent
        case .irregularHeartRhythmEvent: return .irregularHeartRhythmEvent
        case .hypertensionEvent:
            if #available(iOS 26.2, *) { return HKCategoryTypeIdentifier(rawValue: "HKCategoryTypeIdentifierHypertensionEvent") }
            return nil
        case .appleWalkingSteadinessEvent: return .appleWalkingSteadinessEvent
        case .environmentalAudioExposureEvent: return .environmentalAudioExposureEvent
        case .headphoneAudioExposureEvent: return .headphoneAudioExposureEvent
        case .mindfulSession: return .mindfulSession
        case .toothbrushingEvent: return .toothbrushingEvent
        case .handwashingEvent: return .handwashingEvent
        case .menstrualFlow: return .menstrualFlow
        case .intermenstrualBleeding: return .intermenstrualBleeding
        case .infrequentMenstrualCycles: return .infrequentMenstrualCycles
        case .irregularMenstrualCycles: return .irregularMenstrualCycles
        case .persistentIntermenstrualBleeding: return .persistentIntermenstrualBleeding
        case .prolongedMenstrualPeriods: return .prolongedMenstrualPeriods
        case .cervicalMucusQuality: return .cervicalMucusQuality
        case .ovulationTestResult: return .ovulationTestResult
        case .progesteroneTestResult: return .progesteroneTestResult
        case .sexualActivity: return .sexualActivity
        case .contraceptive: return .contraceptive
        case .pregnancy: return .pregnancy
        case .pregnancyTestResult: return .pregnancyTestResult
        case .lactation: return .lactation
        case .abdominalCramps: return .abdominalCramps
        case .bloating: return .bloating
        case .constipation: return .constipation
        case .diarrhea: return .diarrhea
        case .heartburn: return .heartburn
        case .nausea: return .nausea
        case .vomiting: return .vomiting
        case .appetiteChanges: return .appetiteChanges
        case .chills: return .chills
        case .dizziness: return .dizziness
        case .fainting: return .fainting
        case .fatigue: return .fatigue
        case .fever: return .fever
        case .generalizedBodyAche: return .generalizedBodyAche
        case .hotFlashes: return .hotFlashes
        case .chestTightnessOrPain: return .chestTightnessOrPain
        case .coughing: return .coughing
        case .rapidPoundingOrFlutteringHeartbeat: return .rapidPoundingOrFlutteringHeartbeat
        case .shortnessOfBreath: return .shortnessOfBreath
        case .skippedHeartbeat: return .skippedHeartbeat
        case .wheezing: return .wheezing
        case .lowerBackPain: return .lowerBackPain
        case .headache: return .headache
        case .memoryLapse: return .memoryLapse
        case .moodChanges: return .moodChanges
        case .lossOfSmell: return .lossOfSmell
        case .lossOfTaste: return .lossOfTaste
        case .runnyNose: return .runnyNose
        case .soreThroat: return .soreThroat
        case .sinusCongestion: return .sinusCongestion
        case .breastPain: return .breastPain
        case .pelvicPain: return .pelvicPain
        case .vaginalDryness: return .vaginalDryness
        case .acne: return .acne
        case .drySkin: return .drySkin
        case .hairLoss: return .hairLoss
        case .nightSweats: return .nightSweats
        case .sleepChanges: return .sleepChanges
        case .bladderIncontinence: return .bladderIncontinence
        default: return nil
        }
    }
    var sampleType: HKSampleType? {
        if let identifier = quantityIdentifier { return HKObjectType.quantityType(forIdentifier: identifier) }
        if let identifier = categoryIdentifier { return HKObjectType.categoryType(forIdentifier: identifier) }
        switch self {
        case .electrocardiograms: return HKObjectType.electrocardiogramType()
        case .heartbeatSeries: return HKSeriesType.heartbeat()
        case .workoutRoutes: return HKSeriesType.workoutRoute()
        case .audiograms: return HKObjectType.audiogramSampleType()
        case .stateOfMind:
            if #available(iOS 18.0, *) { return HKObjectType.stateOfMindType() }
            return nil
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
        case .runningGroundContactTime: return (.secondUnit(with: .milli), "ms", 1)
        case .runningPower, .cyclingFunctionalThresholdPower, .cyclingPower: return (.watt(), "W", 1)
        case .runningSpeed, .cyclingSpeed, .crossCountrySkiingSpeed, .paddleSportsSpeed, .rowingSpeed, .walkingSpeed, .stairAscentSpeed, .stairDescentSpeed: return (.meter().unitDivided(by: .second()), "m/s", 1)
        case .runningStrideLength, .runningVerticalOscillation, .walkingStepLength: return (.meterUnit(with: .centi), "cm", 1)
        case .pushCount, .swimmingStrokeCount, .nikeFuel, .appleSleepingBreathingDisturbances, .inhalerUsage, .numberOfTimesFallen, .uvExposure, .numberOfAlcoholicBeverages: return (.count(), "count", 1)
        case .distanceWheelchair, .distanceDownhillSnowSports, .distanceCrossCountrySkiing, .distancePaddleSports, .distanceRowing, .distanceSkatingSports: return (.meterUnit(with: .kilo), "km", 1)
        case .distanceSwimming, .sixMinuteWalkTestDistance, .underwaterDepth: return (.meter(), "m", 1)
        case .appleMoveTime, .appleStandTime, .timeInDaylight: return (.minute(), "min", 1)
        case .cyclingCadence: return (.count().unitDivided(by: .minute()), "rpm", 1)
        case .physicalEffort: return (.kilocalorie().unitDivided(by: .gramUnit(with: .kilo)).unitDivided(by: .hour()), "kcal/kg/h (MET)", 1)
        case .estimatedWorkoutEffortScore, .workoutEffortScore: 
            if #available(iOS 18.0, *) { return (.appleEffortScore(), "effort", 1) }
            return nil
        case .basalBodyTemperature, .appleSleepingWristTemperature, .waterTemperature: return (.degreeCelsius(), "°C", 1)
        case .environmentalAudioExposure, .environmentalSoundReduction, .headphoneAudioExposure: return (.decibelAWeightedSoundPressureLevel(), "dBA", 1)
        case .heartRateRecoveryOneMinute: return (.count().unitDivided(by: .minute()), "bpm", 1)
        case .atrialFibrillationBurden, .peripheralPerfusionIndex, .appleWalkingSteadiness, .walkingAsymmetryPercentage, .walkingDoubleSupportPercentage, .bloodAlcoholContent: return (.percent(), "%", 100)
        case .electrodermalActivity: return (.siemenUnit(with: .micro), "µS", 1)
        case .forcedExpiratoryVolume1, .forcedVitalCapacity: return (.liter(), "L", 1)
        case .insulinDelivery: return (.internationalUnit(), "IU", 1)
        case .peakExpiratoryFlowRate: return (.liter().unitDivided(by: .minute()), "L/min", 1)
        case .dietaryBiotin, .dietaryChromium, .dietaryFolate, .dietaryIodine, .dietaryMolybdenum, .dietarySelenium, .dietaryVitaminA, .dietaryVitaminB12, .dietaryVitaminD, .dietaryVitaminK: return (.gramUnit(with: .micro), "µg", 1)
        case .dietaryCaffeine, .dietaryCalcium, .dietaryChloride, .dietaryCholesterol, .dietaryCopper, .dietaryIron, .dietaryMagnesium, .dietaryManganese, .dietaryNiacin, .dietaryPantothenicAcid, .dietaryPhosphorus, .dietaryPotassium, .dietaryRiboflavin, .dietarySodium, .dietaryThiamin, .dietaryVitaminB6, .dietaryVitaminC, .dietaryVitaminE, .dietaryZinc: return (.gramUnit(with: .milli), "mg", 1)
        case .dietaryFatMonounsaturated, .dietaryFatPolyunsaturated, .dietaryFatSaturated, .dietaryFiber, .dietarySugar: return (.gram(), "g", 1)
        default: return nil
        }
    }
    static var available: [Self] { allCases.filter { $0.sampleType != nil } }
    static let suggested: Set<Self> = [.steps, .activeEnergy, .heartRate, .restingHeartRate, .sleep, .weight, .bodyFat, .workouts]
}
