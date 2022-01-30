//
//  HealthKitView.swift
//  healthKitConnector
//
//  Created by Klaus-Dieter Reiners on 06.04.21.
//

import SwiftUI
import HealthKit
struct HealthKitView: View {
    @EnvironmentObject var bo:peas_QuantityTypes
    @State var dateFrom = Date("2017-01-01")
    @State var dateTo = Date("2017-12-31")
    var body: some View {
        ScrollView {
            VStack {
                Button(action: createTestData) {
                        Text("Create Testdata")
                            .font(.largeTitle)
                            .bold()

                }
                Button(action: deleteTestData) {
                        Text("Delete Testdata")
                            .font(.largeTitle)
                            .bold()

                }
//                Button(action: fetchAllHealthData) {
//                        Text("Fetch Samples")
//                            .font(.largeTitle)
//                            .bold()
//
//                }
//                Button(action: updateSources) {
//                        Text("Fetch Sources")
//                            .font(.largeTitle)
//                            .bold()
//
//                }
                Divider()
                Button(action: getStatistics) {
                    Text("StatisticsCollectionQuery")
                        .font(.title)
                        .bold()
                }
                Divider()
                DatePicker(selection: $dateFrom, in: ...Date(), displayedComponents: .date) {
                                Text("StartDate")
                }
            }
        }
    }
    func createTestData() -> Void {
        bo.createTestData(dateFrom: dateFrom)
    }
    func deleteTestData() -> Void {
        bo.deleteTestData {
        }
    }
    func fetchAllHealthData() -> Void {
        bo.fetchAllHealthData()
    }
    func getStatistics() -> Void {
        bo.getStatistics(dateFrom: dateFrom)
    }
    func updateSources() -> Void {
        bo.listOfQuantityTypes.forEach { quantityType in
            quantityType.value.samples.forEach{ sample in
                quantityType.value.CD_updateFromSample(sample: sample)
            }
        }
    }
}
func fetchSources() -> Void {
}

    
//        if success {
//            healthStore.preferredUnits(for: readData, completion: { (results, error) in
//                readData.forEach {
//                    let quantityType = $0
//                    let preferredUnit=results[quantityType]
//                    let query = HKSourceQuery.init(sampleType: quantityType,
//                                                          samplePredicate: nil) { (query, sources, error) in
//                                                           for source in sources! {
//                                                               print("\(source.name) \(quantityType.description) \(preferredUnit!)")
//                                                           }
//                           }
//
//                           healthStore.execute(query)
//                }
//            })
//        }
//    }
//}

func fetchAllSources() {
//    if HKHealthStore.isHealthDataAvailable() {
//        let readData = Set([
//            HKObjectType.quantityType(forIdentifier: .heartRate)!,
//            HKObjectType.quantityType(forIdentifier: .bloodGlucose)!
////            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
//        ])
//        healthStore.requestAuthorization(toShare: [], read: readData) { (success, error) in
//            if success {
//                let calendar = NSCalendar.current
//
//                var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: NSDate() as Date)
//
//                let offset = (7 + anchorComponents.weekday! - 2) % 7
//
//                anchorComponents.day! -= offset
//                anchorComponents.hour = 2
//
//                guard let anchorDate = Calendar.current.date(from: anchorComponents) else {
//                    fatalError("*** unable to create a valid date from the given components ***")
//                }
//
//                let interval = NSDateComponents()
//                interval.hour = 1
//
//                let endDate = Date()
//
//                guard let startDate = calendar.date(byAdding: .month, value: -1, to: endDate) else {
//                    fatalError("*** Unable to calculate the start date ***")
//                }
//                healthStore.preferredUnits(for: readData, completion: { (results, error) in
//                    readData.forEach {
//                        let quantityType = $0
//                        let preferredUnit=results[quantityType]
//                        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
//                                                                quantitySamplePredicate: nil,
//                                                                options:  [.discreteAverage, .separateBySource],
//                                                                    anchorDate: anchorDate,
//                                                                    intervalComponents: interval as DateComponents)
//                        query.initialResultsHandler = {
//                            query, results, error in
//                            guard let statsCollection = results else {
//                                fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
//                            }
//
//                            statsCollection.enumerateStatistics(from: startDate, to: endDate) {
//                                statistics, stop in
//                                if let quantity = statistics.averageQuantity()
//                                {
//                                    let date = statistics.startDate
//                                    let value=quantity.doubleValue(for: preferredUnit!)
//                                    let device=statistics.sources?[0].name
//                                    print("\(device ?? "Unbekanntes Gerät")")
//                                    print("\(value) \(preferredUnit!)")
//                                    print(date)
//                                }
//                            }
//                        }
//                        healthStore.execute(query)
//                    }
//                })
//            }
//            else {
//                print("Authorization failed")
//
//            }
//        }
//    }
}
func fetchDevices() -> Void {
//    let energyBurned = HKQuantityType.quantityType(
//        forIdentifier: HKQuantityTypeIdentifier.bloodGlucose)
//
//        let stepsSampleQuery = HKSampleQuery(sampleType: energyBurned!,
//            predicate: nil,
//            limit: 100000,
//            sortDescriptors: nil)  {
//              (query, results, error) in
//                if let results = results as? [HKQuantitySample] {
//                    for result in results {
//                        print("device: \(result.device) steps:\(result)" )
//                    }
//                }
//        }
//
//    healthStore.execute(stepsSampleQuery)
}

struct HealthKitView_Previews: PreviewProvider {
    static var previews: some View {
        HealthKitView()
    }
}
