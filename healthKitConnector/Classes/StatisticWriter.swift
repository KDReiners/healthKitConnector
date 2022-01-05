//
//  HKStatisticCollection.swift
//  healthKitConnector
//
//  Created by Klaus-Dieter Reiners on 01.01.22.
//

import Foundation
import HealthKit
import CoreData
internal class StatisticWriter {
    var healthStore: HKHealthStore
    var quantityType: HKQuantityType
    var preferredUnit: HKUnit
    var interval = DateComponents()
    let calendar = Calendar.current
    let startDate = Date("2022-01-02")
    var anchorDate : Date
    internal var items : [HKQuantitySample]
    
    init(healthStore: HKHealthStore, quantityType: HKQuantityType, preferredUnit: HKUnit) {
        self.healthStore = healthStore
        self.quantityType = quantityType
        self.preferredUnit = preferredUnit
        self.interval.hour = 4
        self.anchorDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: startDate)!
        self.items = []
        sumQuantity()
        averageQuantity()
        
    }
    struct QueryResult {
        var quantityType: HKQuantityType!
        var aggregationStyle: String!
        var startDate: Date!
        var endDate: Date!
        var sumQuantity: Double?
        var averageQuantity: Double?
        var min: Double?
        var max: Double?
        var mostRecent: Double?
    }
    internal func sumQuantity() -> Void {
        if self.quantityType.aggregationStyle == .cumulative {
            let query = HKStatisticsCollectionQuery.init(quantityType: self.quantityType, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: self.anchorDate, intervalComponents: self.interval)
            query.initialResultsHandler = {
                query, results, error in
                results?.enumerateStatistics(from: self.startDate, to: Date(), with: { (result, stop) in
                    if result.sumQuantity()?.doubleValue(for: self.preferredUnit) ?? 0 > 0 {
                        let quantity = HKQuantity(unit: self.preferredUnit, doubleValue: result.sumQuantity()?.doubleValue(for: self.preferredUnit) ?? 0)
                        let item = HKCumulativeQuantitySample(type: self.quantityType, quantity: quantity, start: result.startDate, end: result.endDate)
                        self.items.append(item)
                        print("Cumulativ Type: \(self.quantityType) Time: \(result.startDate), END: \(result.endDate), Wert: \(result.sumQuantity()?.doubleValue(for: self.preferredUnit) ?? 0)")
                    }
                })
            }
                healthStore.execute(query)
        }
    }
    internal func averageQuantity() -> Void {
        if self.quantityType.aggregationStyle == .discreteArithmetic {
            let query = HKStatisticsCollectionQuery.init(quantityType: self.quantityType, quantitySamplePredicate: nil, options: [.discreteAverage, .discreteMax, .discreteMin, .mostRecent], anchorDate: self.anchorDate, intervalComponents: self.interval)
            query.initialResultsHandler = {
                query, results, error in
                results?.enumerateStatistics(from: self.startDate, to: Date(), with: { (result, stop) in
                    if result.averageQuantity()?.doubleValue(for: self.preferredUnit) ?? 0 > 0 {
                        let quantity = HKQuantity(unit: self.preferredUnit, doubleValue: result.averageQuantity()?.doubleValue(for: self.preferredUnit) ?? 0)
                        var item = HKDiscreteQuantitySample(type: self.quantityType, quantity: quantity, start: result.startDate, end: result.endDate)
                        item.setValue(10, forKeyPath: "dd")
                        self.items.append(item)
                        print("Discrete Type: \(self.quantityType) Time: \(result.startDate), END: \(result.endDate), Wert: \(result.averageQuantity()?.doubleValue(for: self.preferredUnit) ?? 0)")
                    }
                })
            }
                healthStore.execute(query)
        }
    }
}
