//
//  HKStatisticCollection.swift
//  healthKitConnector
//
//  Created by Klaus-Dieter Reiners on 01.01.22.
//

import Foundation
import HealthKit
import CoreData
import SwiftUI
protocol cloud_Delegate: AnyObject {
    func storeInCloud(queryResults: [StatisticWriter.QueryResult])
    func fetchOutdatedLogs(queryResults: [StatisticWriter.QueryResult])
}
internal class StatisticWriter {
    var healthStore: HKHealthStore
    var quantityType: HKQuantityType
    weak var cloudWriter: cloud_Delegate?
    var preferredUnit: HKUnit
    var interval = DateComponents()
    let calendar = Calendar.current
    let startDate = Date("2022-01-01")
    let endDate = Date("2022-01-31")
    var anchorDate : Date
    internal var items : [QueryResult]
    
    init(healthStore: HKHealthStore, quantityType: HKQuantityType, preferredUnit: HKUnit) {
        self.healthStore = healthStore
        self.quantityType = quantityType
        self.preferredUnit = preferredUnit
        self.interval.hour = 1
        self.anchorDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: startDate)!
        self.items = []
    }
    internal struct QueryResult {
        var quantityType: HKQuantityType!
        var sourceName: String?
        var aggregationStyle: String!
        var startDate: Date!
        var endDate: Date!
        var sumQuantity: Double?
        var averageQuantity: Double?
        var minimumQuantity: Double?
        var maximumQuantity: Double?
        var mostRecentQuantity: Double?
        var mostRecentQuantityDateInterval: DateInterval?
        init(hkStatistics: HKStatistics, preferredUnit: HKUnit) {
            startDate = hkStatistics.startDate
            endDate = hkStatistics.endDate
            quantityType = hkStatistics.quantityType
            if hkStatistics.quantityType.aggregationStyle == .cumulative {
                sumQuantity = hkStatistics.sumQuantity()?.doubleValue(for: preferredUnit) ?? 0
            }
            if hkStatistics.quantityType.aggregationStyle == .discreteArithmetic || hkStatistics.quantityType == HKObjectType.quantityType(forIdentifier: .heartRate) {
                averageQuantity = hkStatistics.averageQuantity()?.doubleValue(for: preferredUnit) ?? 0
                minimumQuantity = hkStatistics.minimumQuantity()?.doubleValue(for: preferredUnit) ?? 0
                maximumQuantity = hkStatistics.maximumQuantity()?.doubleValue(for: preferredUnit) ?? 0
                mostRecentQuantity = hkStatistics.mostRecentQuantity()?.doubleValue(for: preferredUnit) ?? 0
                mostRecentQuantityDateInterval = hkStatistics.mostRecentQuantityDateInterval()
            }
        }
    }
internal func gatherInformation(aggregationStyle: HKQuantityAggregationStyle, completion: @escaping() -> Void) -> Void  {
        print("Called gatherInformation for: \(self.quantityType)")
        let options: HKStatisticsOptions = aggregationStyle == .cumulative ? [.cumulativeSum] : [.discreteAverage]
        let query = HKStatisticsCollectionQuery.init(quantityType: self.quantityType, quantitySamplePredicate: nil, options: options, anchorDate: self.anchorDate, intervalComponents: self.interval)
        query.initialResultsHandler = { query, results, error in
            results?.enumerateStatistics(from: self.startDate, to: self.endDate, with: {
                (result, stop) in
                if result.quantityType == self.quantityType {
                    let item = QueryResult(hkStatistics: result, preferredUnit: self.preferredUnit)
                    self.items.append(item)
                }
                else {
                    print("Something went wrong")
                }
            })
            self.cloudWriter?.storeInCloud(queryResults: self.items)
            print("completion from initialResultHandler")
            completion()
        }
        query.statisticsUpdateHandler = { query, statistics, results, error in
            print("In statisticsUpdateHandler...")
            guard let results = results else {
                print("No results")
                return
            }
            self.items.removeAll()
            results.enumerateStatistics(from: self.startDate, to: Date()) { result, stop in
                if result.quantityType == self.quantityType {
                    let item = QueryResult(hkStatistics: result, preferredUnit: self.preferredUnit)
                    self.items.append(item)
                }
                else {
                    print("Something went wrong")
                }
            }
            self.cloudWriter?.storeInCloud(queryResults: self.items)
            print("NO completion from statisticUpdateHandler")
        }
        healthStore.execute(query)
    }
}
