//
//  healthKitConnectorApp.swift
//  healthKitConnector
//
//  Created by Klaus-Dieter Reiners on 21.03.21.
//

import SwiftUI
import HealthKit
import CoreData
import healthKitPackage
@main

struct healthKitConnectorApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        
    }
}
