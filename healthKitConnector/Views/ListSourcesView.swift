//
//  ListSourcesView.swift
//  healthKitConnector
//
//  Created by Klaus-Dieter Reiners on 21.03.21.
//

import SwiftUI
import healthKitPackage
struct ListSourcesView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Source.entity(), sortDescriptors: []) var sources: FetchedResults<Source>
    var body: some View {
                NavigationView {
            List {
                ForEach(sources, id: \.uuid) { source in
                    SourceNameEdit(currentSource:source)
                }
                .onDelete(perform: deleteSources)
            }
            .navigationBarTitle(Text("Sources"), displayMode: .inline)
            .navigationBarItems(leading:
                HStack {
                    Button(action: {self.addSource()}) {
                        Image(systemName: "plus")
                    }
                }, trailing:
                HStack {
                    EditButton()
                }
            )
        }
    }
    func addSource()
    {
        let source = Source(context: moc)
        source.hk_name = "neue Quelle"
        try? moc.save()
    }
    func deleteSources(at offsets: IndexSet) {
        for index in offsets {
            let source = sources[index]
            moc.delete(source)
        }
        try? moc.save()
    }
}
struct ListSourcesView_Previews: PreviewProvider {
    static var previews: some View {
        ListSourcesView()
    }
}

struct SourceNameEdit: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Source.entity(), sortDescriptors: []) var sources: FetchedResults<Source>
    @ObservedObject var currentSource: Source
    var body: some View {
        TextField("Quelle", text: $currentSource.hk_name.bound, onCommit: {
                        nameChanged()
                    })
    }
    func nameChanged() {
        try? moc.save()
    }
}
