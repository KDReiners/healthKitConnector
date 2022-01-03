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
    var items : [QueryResult]
    
    init(healthStore: HKHealthStore, quantityType: HKQuantityType, preferredUnit: HKUnit) {
        self.healthStore = healthStore
        self.quantityType = quantityType
        self.preferredUnit = preferredUnit
        self.interval.hour = 1
        self.anchorDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: startDate)!
        self.items = []
        generateResultContainer()
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
    private func generateResultContainer() -> Void {
        for i in stride(from: self.anchorDate.timeIntervalSince1970, to: Date().timeIntervalSince1970, by: 3600) {
            var item = QueryResult()
            item.quantityType = self.quantityType
            item.startDate = Date(timeIntervalSince1970: i)
            item.endDate = Date(timeIntervalSince1970: i+3600)
            items.append(item)
        }
    }
    private func getResultItem(StartDate: Date) -> QueryResult {
        return self.items.filter { item in
            if item.startDate == StartDate {
                return true
            }
            else {
                return false
            }
        }.first!
    }
    internal func sumQuantity() -> Void {
        if self.quantityType.aggregationStyle == .cumulative {
            let query = HKStatisticsCollectionQuery.init(quantityType: self.quantityType, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: self.anchorDate, intervalComponents: self.interval)
            query.initialResultsHandler = {
                query, results, error in
                results?.enumerateStatistics(from: self.startDate, to: Date(), with: { (result, stop) in
                    var item = self.getResultItem(StartDate: result.startDate)
                    var item2 = HKDiscreteQuantitySample()
                    item2
                    item.aggregationStyle = "cumulative"
                    item.startDate = result.startDate
                    item.endDate = result.endDate
                    item.sumQuantity = result.sumQuantity()?.doubleValue(for: self.preferredUnit)
                    if item.sumQuantity ?? 0 > 0 {
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
                    var item = self.getResultItem(StartDate: result.startDate)
                    item.aggregationStyle = "discreteArithmetic"
                    item.startDate = result.startDate
                    item.endDate = result.endDate
                    item.averageQuantity = result.averageQuantity()?.doubleValue(for: self.preferredUnit)
                    item.max = result.maximumQuantity()?.doubleValue(for: self.preferredUnit)
                    item.min = result.minimumQuantity()?.doubleValue(for: self.preferredUnit)
                    item.mostRecent = result.mostRecentQuantity()?.doubleValue(for: self.preferredUnit)
                    if item.averageQuantity ?? 0 > 0 {
                        
                        print("Discrete Type: \(self.quantityType) Time: \(result.startDate), END: \(result.endDate), Wert: \(result.averageQuantity()?.doubleValue(for: self.preferredUnit) ?? 0)")
                    }
                })
                    
                }
                healthStore.execute(query)
        }
    }
}
