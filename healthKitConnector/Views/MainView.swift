//
//  MainView.swift
//  healthKitConnector
//
//  Created by Klaus-Dieter Reiners on 21.03.21.
//

import SwiftUI
import HealthKit
struct MainView: View {
    @Environment(\.managedObjectContext) var moc
    @StateObject var bo = peas_QuantityTypes()
    var body: some View {
        TabView {
            ListLogsView()
                .tabItem {
                    Label("Log", systemImage: "plus.circle")
                }
            ListSourcesView()
                .tabItem {
                    Label("Sources", systemImage: "gear")
                }
            HealthKitView()
                .tabItem {
                    Label("HealthKit", systemImage: "plus.rectangle.on.folder")
                }.environmentObject(bo)
            ListQuantityTypes()
                .tabItem {
                    Label("Messgrössen", systemImage: "gauge")
                }
        }.onAppear() {
            bo.syncLoadTasks() 
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
