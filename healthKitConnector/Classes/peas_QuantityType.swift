//
//  cls_QuantityType.swift
//  healthKitConnector
//
//  Created by Klaus-Dieter Reiners on 01.05.21.
//
import HealthKit
import Foundation
import CoreData
import UIKit
// MARK: - Classes
class peas_Sample {
    var sourceRevision: HKSourceRevision
    var device: HKDevice?
    var quantityType: HKQuantityType
    var quantity: Double
    var timeStamp: Date
    
    init(sourceRevision: HKSourceRevision, device: HKDevice? = nil, quantity: Double, timeStamp: Date, quantityType: HKQuantityType) {
        self.sourceRevision = sourceRevision
        self.device = device
        self.quantity = quantity
        self.timeStamp = timeStamp
        self.quantityType = quantityType
    }
}
class peas_QuantityType: cloud_Delegate {
    var outdatedLogs = [NSManagedObject]()
    var quantityType: HKQuantityType
    var healthStore: HKHealthStore
    var sources = Set<HKSource>()
    var devices = Set<String>()
    var samples = Array<peas_Sample>()
    var preferredUnit: HKUnit
    var moc: NSManagedObjectContext
    var options: HKStatisticsOptions
    var cd_QuantityType: Quantitytype?
    var cd_Source: Source?
    var cd_Device: Device?
    internal var createTestData: Bool = false
    let deviceInstance = HKDevice(name: "peas" , manufacturer: "Peas", model: "", hardwareVersion: "", firmwareVersion: "", softwareVersion: "", localIdentifier: "", udiDeviceIdentifier: "" )
    
    
    
    init (quantityType: HKQuantityType, preferredUnit: HKUnit, healthStore: HKHealthStore) {
        self.quantityType = quantityType
        self.healthStore = healthStore
        self.preferredUnit  = preferredUnit
        self.options = peas_QuantityTypes.statiticDictionary[quantityType]!
        self.moc = PersistenceController.shared.cloudContainer.viewContext
        self.cd_QuantityType = CD_UpdateQuantityTypes(quantityType: self.quantityType)
        self.cd_Device = CD_updateDevices(device: deviceInstance )
        self.cd_Source = CD_updateSources(sourceRevision: HKSourceRevision(source: HKSource.default(), version: "1.0"))
    }
    func fetchOutdatedLogs(queryResults: [StatisticWriter.QueryResult]) {
        print("Called fetchOutdatedLogs: \(self.quantityType)")
        queryResults.forEach { result in
            if result.sumQuantity ?? 0 > 0 || result.averageQuantity ?? 0 > 0 {
                let candidates = returnQueryResult(queryResult: result)
                candidates?.forEach { candidate in
                    if candidate.value(forKeyPath: "log2quantitytype.hk_quantitytype") != nil {
                        if candidate.value(forKeyPath: "log2quantitytype.hk_quantitytype") as! String == self.quantityType.identifier {
                            outdatedLogs.append(candidate)
                        }
                    }
                    else {
                        print("Warumg ist das so")
                    }
                }
            }
        }
    }
    func storeInCloud(queryResults: [StatisticWriter.QueryResult]) {
        print("Called storeInCloud for: \(self.quantityType)")
        fetchOutdatedLogs(queryResults: queryResults)
        deleteLogsFromCloud(logs: outdatedLogs)
        queryResults.forEach { result in
            var logValue: Double = 0.00
            if result.averageQuantity != nil || result.sumQuantity != nil {
                logValue = (result.averageQuantity == nil ? result.sumQuantity! : result.averageQuantity!)
            }
            if logValue != 0 {
                var cd_Log = Log(context: moc)
                cd_Log.timeStamp = result.startDate
                cd_Log.uuid = UUID()
                cd_Log.value = logValue as NSNumber
                cd_Log.log2quantitytype = cd_QuantityType
                cd_Log.log2source = cd_Source
                cd_Log.log2Device = cd_Device
//                cd_Save()
            }
        }
    }
    fileprivate func storeSamples(_ samples: [HKQuantitySample]) {
        createTestData = true
        samples.forEach { sample in
            let newSample = peas_Sample(sourceRevision: sample.sourceRevision, device: sample.device, quantity: sample.quantity.doubleValue(for: self.preferredUnit), timeStamp: sample.startDate, quantityType: sample.quantityType)
            self.samples.append(newSample)
        }
        createTestData = false
    }
    func deleteLogsFromCloud(logs: [NSManagedObject]?) {
        guard let logs = logs else { return }
        logs.forEach{ log in
            moc.delete(log)
        }
    }
    // MARK: - Interact with healthStore
    func upDateHealthData(completion: @escaping() -> Void) {
        var anchor: HKQueryAnchor? = nil
        let key = String(format: "Anchor_%@", self.quantityType)
        if UserDefaults.standard.object(forKey: key) != nil {
            let data = UserDefaults.standard.object(forKey: key) as! Data
            anchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data)
        }
        else {
            anchor = HKQueryAnchor.init(fromValue: 0)
        }
        let startDate = Date("2018-01-07")
        let endDate = Date("2018-12-31")
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictEndDate)
        let query = HKAnchoredObjectQuery(type: self.quantityType,
                                          predicate: nil,
                                          anchor: anchor,
                                          limit: HKObjectQueryNoLimit)
        { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            
            guard let samples = samplesOrNil, let deletedObjects = deletedObjectsOrNil else {
                // Properly handle the error.
                return
            }
            guard let samples = samples as? [HKQuantitySample] else { return }
            anchor = newAnchor!
            for sample in samples {
                print("samples: \(sample)")
            }
            self.storeSamples(samples)
            for deletedSample in deletedObjects {
                print("deleted sample: \(deletedSample)")
            }

            // The results come back on an anonymous background queue.
            // Dispatch to the main queue before modifying the UI.
            let data : Data = try! NSKeyedArchiver.archivedData(withRootObject: newAnchor as Any, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey:key)
            completion()
        }
        query.updateHandler = { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            guard let samples = samplesOrNil, let deletedObjects = deletedObjectsOrNil else {
                // Properly handle the error.
                return
            }
            anchor = newAnchor!
            let data : Data = try! NSKeyedArchiver.archivedData(withRootObject: newAnchor as Any, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey:key)
            
            guard let samples = samples as? [HKQuantitySample] else { return }
            self.storeSamples(samples)
     
            for deletedSample in deletedObjects {
                print("deleted: \(deletedSample)")
            }
        }
        self.healthStore.execute(query)
    }

    // MARK: - Interact with coreData
    func cd_Save() {
        do {
            if moc.hasChanges {
                try moc.save()
            }
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func CD_updateFromSample(sample: peas_Sample) {
        let source = CD_updateSources(sourceRevision: sample.sourceRevision)
        let quantityType = CD_UpdateQuantityTypes(quantityType: sample.quantityType)
        let device = CD_updateDevices(device: sample.device)
        let log = CD_updateLog(log: sample)
        source!.addToSource2logs(log)
        quantityType.addToQuantitytype2logs(log)
        device?.addToDevice2Logs(log)
        source?.addToSource2logs(log)
        cd_Save()
    }
    internal func CD_updateLog(log: peas_Sample) ->Log {
        let cd_Log = Log(context: moc)
        cd_Log.timeStamp = log.timeStamp
        cd_Log.uuid = UUID()
        cd_Log.value = log.quantity as NSNumber
        cd_Save()
        return cd_Log
    }
    private func CD_updateDevices(device: HKDevice?) -> Device? {
        var result: Device?
        if device != nil {
            if let cd_Device = returnItemForAttributeOfEntity(entity: "Device", uniqueIdentity: (device?.name)!, idAttributeName: "hk_name") {
                result = cd_Device as? Device
            }else {
                let cd_Device = Device(context: moc)
                cd_Device.hk_name = (device?.name)!
                cd_Device.uuid = UUID()
                cd_Save()
                result = cd_Device
            }
        }
        return result
    }
    private func CD_updateSources(sourceRevision: HKSourceRevision) -> Source? {
        var result: Source?
        if let cd_Source = returnItemForAttributeOfEntity(entity: "Source", uniqueIdentity: sourceRevision.source.name, idAttributeName: "hk_name") {
            result = cd_Source as? Source
        }else {
            let cd_Source = Source(context: moc)
            cd_Source.hk_name = sourceRevision.source.name
            cd_Source.uuid = UUID()
            cd_Save()
            result = cd_Source
        }
        return result
    }
    private func CD_UpdateQuantityTypes(quantityType: HKQuantityType) -> Quantitytype {
        var result: Quantitytype
        if let cd_Quantitytype = returnItemForAttributeOfEntity(entity: "Quantitytype", uniqueIdentity: quantityType.identifier, idAttributeName: "hk_quantitytype") {
            result = cd_Quantitytype as! Quantitytype
        } else {
            let cd_QuantityType = Quantitytype(context: moc)
            cd_QuantityType.hk_quantitytype = quantityType.identifier
            cd_QuantityType.uuid = UUID()
            cd_QuantityType.delay = 0
            cd_QuantityType.preferredUnit = self.preferredUnit.unitString
            cd_Save()
            result = cd_QuantityType
        }
        return result
    }
    internal func getStatistics(completion: @escaping() -> Void) {
        if createTestData == false {
            let statisticWriter = StatisticWriter(healthStore: self.healthStore, quantityType: self.quantityType, preferredUnit: self.preferredUnit)
            statisticWriter.cloudWriter = self
            statisticWriter.gatherInformation(aggregationStyle: self.quantityType.aggregationStyle) {
                completion()
            }
        }
        else {
            completion()
        }
    }
    // MARK: Helpers
    func returnQueryResult(queryResult: StatisticWriter.QueryResult) -> [NSManagedObject]? {
        let quantityType = queryResult.quantityType
        let timeStamp = queryResult.startDate
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Log")
        fetchRequest.predicate = NSPredicate(format: "timeStamp = %@ AND log2quantitytype.hk_quantitytype = %@" , timeStamp! as NSDate, quantityType!)
        var results: [NSManagedObject] = []
        do {
            results = try moc.fetch(fetchRequest)
        }
        catch {
            print("error    executing fetch request: \(error)")
        }
       return results
    }
    func returnItemForAttributeOfEntity(entity: String, uniqueIdentity: String,idAttributeName:String, idDate: Date? = nil, quantityType: peas_QuantityType? = nil) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        if entity != "Log" {
            fetchRequest.predicate = NSPredicate(format: "\(idAttributeName) =  %@", uniqueIdentity)
        }
        else {
            
            fetchRequest.predicate = NSPredicate(format: "\(idAttributeName) == %@", idDate! as CVarArg)
        }
        var result: NSManagedObject?
        var results: [NSManagedObject] = []

        do {
            results = try moc.fetch(fetchRequest)
        }
        catch {
            print("error    executing fetch request: \(error)")
        }
        if results.count > 1 {
            fatalError("Duplicated item at entity: \(entity)")
        }
        if results.count == 1 {
            result = results[0]
        }
        return result

    }
}
