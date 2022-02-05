//
//  Model.swift
//  healthKitShaman
//
//  Created by Klaus-Dieter Reiners on 19.11.21.
//
import CoreData
import Combine
class Model<T>: GenericViewModel where T: NSManagedObject {
    var items: [T] = []
    let context = PersistenceController.shared.cloudContainer.viewContext
    var attributes: Array<EntityAttributeInfo> = BaseServices.getAttributesForEntity(entity: T.self.entity())
    var readOnlyAttributes: Array<EntityAttributeInfo> = []
    var readWriteAttributes: Array<EntityAttributeInfo> = []
    var readOnlyFields: [String] = []
    private var deviceCancellable: AnyCancellable?
    init(readOnlyFields: [String]){
        self.readOnlyFields = readOnlyFields
        BaseServices.returnAttributeCluster(readOnlyFields: readOnlyFields, attributes: &attributes, readOnlyAttributes: &readOnlyAttributes, readWriteAttributes: &readWriteAttributes)
        attachValues()
    }
    
    func attachValues (devicePublisher: AnyPublisher<[T], Never> = Storage<T>().items.eraseToAnyPublisher()) {
        deviceCancellable = devicePublisher.sink { items in
            self.items = items
        }
        BaseServices.returnAttributeCluster(readOnlyFields: readOnlyFields, attributes: &attributes, readOnlyAttributes: &readOnlyAttributes, readWriteAttributes: &readWriteAttributes)
    }
}
