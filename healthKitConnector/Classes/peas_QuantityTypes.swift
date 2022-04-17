//
//  peas_QuantityTypes.swift
//  healthKitConnector
//
//  Created by Klaus-Dieter Reiners on 15.05.21.
//
import HealthKit
import Foundation
import CoreData
import SwiftUI
import CloudKit
import healthKitPackage

class peas_QuantityTypes: ObservableObject {
    internal let healthStore = HKHealthStore()
    static internal var statiticDictionary: Dictionary<HKQuantityType, HKStatisticsOptions> = [
        HKObjectType.quantityType(forIdentifier: .heartRate)!: .discreteAverage,
        HKObjectType.quantityType(forIdentifier: .bloodGlucose)! : HKStatisticsOptions.discreteMin,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)! : HKStatisticsOptions.mostRecent,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)! : HKStatisticsOptions.discreteAverage,
        HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)! : HKStatisticsOptions.cumulativeSum,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)! : HKStatisticsOptions.cumulativeSum,
        HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)! : HKStatisticsOptions.cumulativeSum,
        HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!: HKStatisticsOptions.discreteAverage,
        HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!: HKStatisticsOptions.discreteAverage]
    
    var moc: NSManagedObjectContext
    var container = CKContainer.init(identifier: "iCloud.peas")
    var quantityTypeViewModel = QuantityTypeModel()
    var db : CKDatabase?
    fileprivate let readData =  Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                                    HKObjectType.quantityType(forIdentifier: .bloodGlucose)!,
                                    HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                                    HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                                    HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                                    HKObjectType.quantityType(forIdentifier:  .basalEnergyBurned)!,
                                    HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
                                    HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!])
    fileprivate let writeData = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                                    HKObjectType.quantityType(forIdentifier: .bloodGlucose)!,
                                    HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                                    HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                                    HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                                    HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
                                    HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
                                    HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!])
    
    internal var listOfQuantityTypes = Dictionary<String, peas_QuantityType>()
    init() {
        self.moc=PersistenceController.shared.container.viewContext
        //setupCloudkitInteraction()
    }
    func setupCloudkitInteraction() -> Void {
        if let containerIdentifier = container.containerIdentifier {
            print(containerIdentifier)
            db = container.privateCloudDatabase
            let newSubscription = CKQuerySubscription(recordType: "cd_Log", predicate: NSPredicate(value: true), options: [.firesOnRecordCreation, .firesOnRecordDeletion])
            let notification = CKSubscription.NotificationInfo()
            notification.shouldSendContentAvailable = true
        
            newSubscription.notificationInfo = notification
            db!.save(newSubscription) { (subscription, error) in
                 if let error = error {
                      print(error)
                      return
                 }

                 if let _ = subscription {
                      print("Hurrah! We have a subscription")
                 }
            }
            
        }
        
    }
    func syncLoadTasks() {
        
        isAllowed(completion: { result in
            let preferredUnits = DispatchQueue.global(qos: .default)
            preferredUnits.async { [self] in
                healthStore.preferredUnits(for: readData, completion: { (results, error) in
                    addQuantityType(results: results, Error: error)
                })
                func addQuantityType(results: [HKQuantityType : HKUnit], Error:Error?) ->Void {
                    readData.forEach {
                        if healthStore.authorizationStatus(for: $0) == HKAuthorizationStatus.sharingAuthorized {
                            let qt: peas_QuantityType = peas_QuantityType(quantityType: $0, preferredUnit: results[$0]!, healthStore: healthStore)
                                listOfQuantityTypes[$0.identifier] = qt
                        }
                    }
                }
            }
        })
    }
    func isAllowed(completion: @escaping((_ success: Bool) -> Void)) {
        healthStore.requestAuthorization(toShare: writeData, read: readData) { (success, error) in
            completion(success)
        }
    }
    func fetchAllHealthData()->Void {
        let group = DispatchGroup()
        for (_, peas_quantityType) in listOfQuantityTypes {
            group.enter()
            peas_quantityType.upDateHealthData() {
                group.leave()
            }
        }
        group.wait()
    }
    func getStatistics(dateFrom: Date) -> Void {
        let group = DispatchGroup()
        listOfQuantityTypes.forEach { quantityType in
            print("Called getStatistics for: \(quantityType.key)")
            group.enter()
            quantityType.value.getStatistics(dateFrom: dateFrom) {recordCount in
                print("RecordCount = \(recordCount)")
                print("********** End **********")
                print("")
                group.leave()
            }
            group.wait()
            listOfQuantityTypes.forEach { quantityType in
                quantityType.value.deleteLogsFromCloud(logs: quantityType.value.outdatedLogs)
            }
            do {
                try self.moc.save()
            }
            catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }

    func CD_returnItem(entity: String, uniqueIdentity: String,idAttributeName:String) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        fetchRequest.predicate = NSPredicate(format: "\(idAttributeName) CONTAINS[cd] %@", uniqueIdentity)

        var results: [NSManagedObject] = []

        do {
            results = try moc.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        if results.count>1 {
            fatalError("Uniqueness of items in \(entity) violated")
        }
        else {
            return results[0]
        }
    }
    func createTestData(dateFrom: Date) {
        let sampleCount: Int = 100
        self.listOfQuantityTypes.forEach { type in
            print("Creating sample data for quantityType: \(type.value.quantityType)")
            var factor: Double = 1
            var quantityRaw: Double = 100
            for hour in 1...sampleCount {
                let entryDateFrom = Calendar.current.date(byAdding: .hour, value: hour, to: dateFrom)!
                let quantity = HKQuantity(unit: type.value.preferredUnit, doubleValue: Double(quantityRaw + factor))
                print("\(quantity.doubleValue(for: type.value.preferredUnit))")
                writeQuantitySample(type: type.value.quantityType, quantity: quantity, start: entryDateFrom, end: entryDateFrom,  metaData: [:] )
                quantityRaw = quantity.doubleValue(for: type.value.preferredUnit)
                if quantityRaw > 149 {
                    factor = -1
                }
                if quantityRaw < 51 {
                    factor = 1
                }
               
//                changeQuantity = changeQuantity + factor
              
            }
        }
    }
    func writeQuantitySample(type: HKQuantityType, quantity: HKQuantity, start: Date, end: Date, metaData:[String: Any]? ) {
        let deviceName = String(format: "%@_device", type.identifier)
        let device=HKDevice(name: deviceName , manufacturer: "Peas", model: "", hardwareVersion: "", firmwareVersion: "", softwareVersion: "", localIdentifier: "", udiDeviceIdentifier: "" )
        
        let sample = HKQuantitySample(type: type, quantity: quantity, start: start, end: end, device: device, metadata: metaData)
        HKHealthStore().save(sample) { (success, error) in
              
            if let error = error {
              print("Error Saving Sample: \(error.localizedDescription)")
            } else {
              print("Successfully saved Sample")
            }
        }
    }
    func deleteTestData(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        self.listOfQuantityTypes.forEach { sampleType in
            group.enter()
            deleteTestdataForQuantityType(sampleType: sampleType.value) {
                group.leave()
            }
        }
        group.wait()
        completion()
    }
    func deleteTestdataForQuantityType(sampleType: peas_QuantityType, Completion: @escaping() -> Void ) {
        let group = DispatchGroup()
        group.enter()
        let predicate = NSPredicate(format: "metadata.%K != YES", HKMetadataKeyWasUserEntered)
        let sampleQuery = HKSampleQuery(sampleType: sampleType.quantityType,
                                        predicate: predicate,
                                        limit: HKObjectQueryNoLimit,
                                        sortDescriptors: []) {(query, samples, error) in
            if let querySample = samples as? [HKQuantitySample] {
                for sample in querySample {
                    group.enter()
                    self.healthStore.delete(sample, withCompletion: { (query, error) in
                        if let err = error {
                            print("———> Could not delete sample \(sample.sampleType.identifier) from HealthKit:\(err)")
                        } else {
                            print("------> Deleted sample from healthkit \(sample.quantityType.description)")
                            group.leave()
                        }
                    })
                }
            }
            group.leave()
        }
        self.healthStore.execute(sampleQuery)
        group.wait()
        Completion()
    }
}
