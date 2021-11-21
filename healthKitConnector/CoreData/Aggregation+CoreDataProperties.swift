//
//  Aggregation+CoreDataProperties.swift
//  
//
//  Created by Klaus-Dieter Reiners on 20.11.21.
//
//

import Foundation
import CoreData


extension Aggregation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Aggregation> {
        return NSFetchRequest<Aggregation>(entityName: "Aggregation")
    }

    @NSManaged public var friendlyname: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var aggregation2quantitytypes: NSSet?

}

// MARK: Generated accessors for aggregation2quantitytypes
extension Aggregation {

    @objc(addAggregation2quantitytypesObject:)
    @NSManaged public func addToAggregation2quantitytypes(_ value: Quantitytype)

    @objc(removeAggregation2quantitytypesObject:)
    @NSManaged public func removeFromAggregation2quantitytypes(_ value: Quantitytype)

    @objc(addAggregation2quantitytypes:)
    @NSManaged public func addToAggregation2quantitytypes(_ values: NSSet)

    @objc(removeAggregation2quantitytypes:)
    @NSManaged public func removeFromAggregation2quantitytypes(_ values: NSSet)

}
