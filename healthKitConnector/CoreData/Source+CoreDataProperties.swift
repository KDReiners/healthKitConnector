//
//  Source+CoreDataProperties.swift
//  
//
//  Created by Klaus-Dieter Reiners on 20.11.21.
//
//

import Foundation
import CoreData


extension Source {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Source> {
        return NSFetchRequest<Source>(entityName: "Source")
    }

    @NSManaged public var hk_bundleIdentifier: String?
    @NSManaged public var hk_name: String?
    @NSManaged public var hk_operatingSystemVersion: String?
    @NSManaged public var hk_productType: String?
    @NSManaged public var hk_version: String?
    @NSManaged public var isdefault: Bool
    @NSManaged public var uuid: UUID?
    @NSManaged public var friendlyname: String?
    @NSManaged public var source2logs: NSSet?

}

// MARK: Generated accessors for source2logs
extension Source {

    @objc(addSource2logsObject:)
    @NSManaged public func addToSource2logs(_ value: Log)

    @objc(removeSource2logsObject:)
    @NSManaged public func removeFromSource2logs(_ value: Log)

    @objc(addSource2logs:)
    @NSManaged public func addToSource2logs(_ values: NSSet)

    @objc(removeSource2logs:)
    @NSManaged public func removeFromSource2logs(_ values: NSSet)

}
