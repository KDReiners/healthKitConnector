//
//  Log+CoreDataProperties.swift
//  
//
//  Created by Klaus-Dieter Reiners on 20.11.21.
//
//

import Foundation
import CoreData


extension Log {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Log> {
        return NSFetchRequest<Log>(entityName: "Log")
    }

    @NSManaged public var timeStamp: Date?
    @NSManaged public var uuid: UUID?
    @NSManaged public var value: NSNumber?
    @NSManaged public var log2Device: Device?
    @NSManaged public var log2quantitytype: Quantitytype?
    @NSManaged public var log2source: Source?

}
