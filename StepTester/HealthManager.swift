import Foundation
import HealthKit
import Combine   // <-- add this line if it's missing

final class HealthManager: ObservableObject {
    private let store = HKHealthStore()
    private let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        store.requestAuthorization(toShare: [stepType], read: [stepType]) { ok, _ in
            completion(ok)
        }
    }

    func writeSteps(_ count: Int, start: Date, end: Date, completion: @escaping (Bool) -> Void) {
        let qty = HKQuantity(unit: .count(), doubleValue: Double(count))
        let sample = HKQuantitySample(type: stepType, quantity: qty, start: start, end: end)
        store.save(sample) { ok, _ in completion(ok) }
    }

    func fetchRecentSamples(hoursBack: Int = 24, completion: @escaping ([HKQuantitySample]) -> Void) {
        let from = Calendar.current.date(byAdding: .hour, value: -hoursBack, to: Date())!
        let pred = HKQuery.predicateForSamples(withStart: from, end: Date(), options: .strictEndDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let q = HKSampleQuery(sampleType: stepType, predicate: pred, limit: 20, sortDescriptors: [sort]) { _, results, _ in
            completion((results as? [HKQuantitySample]) ?? [])
        }
        store.execute(q)
    }
}

