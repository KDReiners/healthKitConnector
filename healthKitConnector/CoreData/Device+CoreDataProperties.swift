//
//  Device+CoreDataProperties.swift
//  
//
//  Created by Klaus-Dieter Reiners on 20.11.21.
//
//

import Foundation
import CoreData


extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }

    @NSManaged public var hk_firmwareVersion: String?
    @NSManaged public var hk_hardwareVersion: String?
    @NSManaged public var hk_localIdentifier: String?
    @NSManaged public var hk_manufacturer: String?
    @NSManaged public var hk_model: String?
    @NSManaged public var hk_name: String?
    @NSManaged public var hk_softwareVersion: String?
    @NSManaged public var hk_udiDeviceIdentifier: String?
    @NSManaged public var isdefault: Bool
    @NSManaged public var uuid: UUID?
    @NSManaged public var friendlyname: String?
    @NSManaged public var device2Logs: NSSet?

}

// MARK: Generated accessors for device2Logs
extension Device {

    @objc(addDevice2LogsObject:)
    @NSManaged public func addToDevice2Logs(_ value: Log)

    @objc(removeDevice2LogsObject:)
    @NSManaged public func removeFromDevice2Logs(_ value: Log)

    @objc(addDevice2Logs:)
    @NSManaged public func addToDevice2Logs(_ values: NSSet)

    @objc(removeDevice2Logs:)
    @NSManaged public func removeFromDevice2Logs(_ values: NSSet)

}
