//
//  BaseServices.swift
//  healthKitShaman
//
//  Created by Klaus-Dieter Reiners on 19.11.21.
//

import Foundation
import OSLog
import CoreData
struct BaseServices
{
    internal static let logger = {
        return Logger()
    }()
    internal static let standardDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    internal static func getAttributesForEntity(entity: NSEntityDescription) -> Array<EntityAttributeInfo> {
        var result = Array<EntityAttributeInfo>()
        let attributes = entity.attributesByName
        attributes.forEach { attribute in
            let newInfo = EntityAttributeInfo.init(key: attribute.key, value: attribute.value.attributeValueClassName!)
            result.append(newInfo)
        }
        return result
        
    }
    internal static func returnAttributeCluster(readOnlyFields: [String], attributes: inout [EntityAttributeInfo], readOnlyAttributes: inout [EntityAttributeInfo], readWriteAttributes: inout [EntityAttributeInfo] ) -> Void {
        for i in 0..<attributes.count {
            
            for readOnly in readOnlyFields {
                if attributes[i].key == readOnly {
                    attributes[i].readOnly = true
                }
            }
        }
        readOnlyAttributes = attributes.filter { $0.readOnly == true}.sorted {
            return $0.key < $1.key
        }
        readWriteAttributes = attributes.filter { $0.readOnly == false}.sorted {
            return $0.key < $1.key
        }
    }
}
