//
//  ListQuantityTypes.swift
//  healthKitConnector
//
//  Created by Klaus-Dieter Reiners on 11.04.21.
//

import SwiftUI
import healthKitPackage
struct ListQuantityTypes: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Quantitytype.entity(), sortDescriptors: []) var quantityTypes: FetchedResults<Quantitytype>
    var body: some View {
        NavigationView {
            List {
                ForEach(quantityTypes, id:\.uuid) { quantityType in
                    VStack(alignment: .trailing) {
                        QuantityTypeEdit(currentQuantityType: quantityType)
                    }
                }
            }
            .navigationBarTitle(Text("Messgrössen"), displayMode: .inline)
            .navigationBarItems(leading:
                HStack {
                    Button(action: {self.addLog()}) {
                        Image(systemName: "plus")
                    }
                }, trailing:
                HStack {
                    EditButton()
                })
        }
    }
    func addLog()
    {
        let quantityType = Quantitytype(context: moc)
        quantityType.friendlyname = "Neue Messgröße"
        quantityType.hk_quantitytype = "unbekannt"
    }
}

struct ListQuantityTypes_Previews: PreviewProvider {
    static var previews: some View {
        ListQuantityTypes()
    }
}
struct QuantityTypeEdit: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Quantitytype.entity(), sortDescriptors: []) var quantityType: FetchedResults<Quantitytype>
    @ObservedObject var currentQuantityType: Quantitytype
    var body: some View {
        VStack {
            TextField("QuantityType", text: $currentQuantityType.friendlyname.bound, onCommit: {
                try? moc.save()
            })
            TextField("HealthkitName", text: $currentQuantityType.hk_quantitytype.bound, onCommit: {
                try? moc.save()
            })
        }
    }
}
