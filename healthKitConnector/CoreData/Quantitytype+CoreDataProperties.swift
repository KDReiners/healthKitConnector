//
//  Quantitytype+CoreDataProperties.swift
//  
//
//  Created by Klaus-Dieter Reiners on 20.11.21.
//
//

import Foundation
import CoreData


extension Quantitytype {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Quantitytype> {
        return NSFetchRequest<Quantitytype>(entityName: "Quantitytype")
    }

    @NSManaged public var delay: Int16
    @NSManaged public var hk_quantitytype: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var preferredUnit: String?
    @NSManaged public var friendlyname: String?
    @NSManaged public var rangefrom: Int16
    @NSManaged public var rangeto: Int16
    @NSManaged public var quantitytype2aggregation: Aggregation?
    @NSManaged public var quantitytype2logs: NSSet?

}

// MARK: Generated accessors for quantitytype2logs
extension Quantitytype {

    @objc(addQuantitytype2logsObject:)
    @NSManaged public func addToQuantitytype2logs(_ value: Log)

    @objc(removeQuantitytype2logsObject:)
    @NSManaged public func removeFromQuantitytype2logs(_ value: Log)

    @objc(addQuantitytype2logs:)
    @NSManaged public func addToQuantitytype2logs(_ values: NSSet)

    @objc(removeQuantitytype2logs:)
    @NSManaged public func removeFromQuantitytype2logs(_ values: NSSet)

}
