//
//  ListLogsView.swift
//  healthKitConnector
//
//  Created by Klaus-Dieter Reiners on 24.03.21.
//

import SwiftUI
import CoreData
struct ListLogsView: View {
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Log.timeStamp, ascending: true)
        ]
    ) var logs: FetchedResults<Log>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(logs, id: \.uuid) {log in
                    VStack(alignment: .trailing) {
                        Text("\(log.timeStamp!, formatter: logFormatter)")
                            .frame(maxWidth: .infinity,
                                alignment: .leading)
                        Text(decimalFormatter.string(from: NSNumber(value: log.value))!)
                            .frame(maxWidth: .infinity,
                                   alignment: .trailing)
                            .font(.subheadline)
//                        SourcesPicker(currentLog: log)
//                            .frame(maxWidth: .infinity,
//                                alignment: .leading)
//                            .font(.body)
                        QuantityTypePicker(currentLog: log)
                            .frame(maxWidth: .infinity,
                                alignment: .leading)
                            .font(.body)
                    }
                   
                }
                .onDelete(perform: deleteLogs)
                
            }
            .navigationBarTitle(Text("Logs"), displayMode: .inline)
            .navigationBarItems(leading:
                HStack {
                    Button(action: {self.addLog()}) {
                        Image(systemName: "plus")
                    }
                }, trailing:
                HStack {
                    EditButton()
                }
            )
        }
    }
    func deleteLogs(at offsets: IndexSet) {
        for index in offsets {
            let log = logs[index]
            moc.delete(log)
        }
    }
    func addLog()
    {
        let log = Log(context: moc)
        log.timeStamp = Date()
        log.value = 0
    }
}

private let logFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    formatter.locale = .init(identifier: "de")
    return formatter
}()
private let decimalFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 3
    return formatter
}()

struct ListLogsView_Previews: PreviewProvider {
    static var previews: some View {
        return ListLogsView()
    }
}
struct SourcesPicker: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Source.entity(), sortDescriptors: []) var sources: FetchedResults<Source>
    @State var currentLog: Log
    var body: some View {
        Picker("", selection: $currentLog.log2source) {
            ForEach(sources, id: \.self) { source in
                Text(source.hk_name ?? "").tag(source as Source?)
            }
        }
        .onChange(of: currentLog.log2source, perform: { (value) in
                                    pickerChanged()

        })
    }
    func pickerChanged() {
        try? moc.save()
    }
}
struct QuantityTypePicker: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Quantitytype.entity(), sortDescriptors: []) var quantityTypes: FetchedResults<Quantitytype>
    @State var currentLog: Log
    var body: some View {
        Picker("", selection: $currentLog.log2quantitytype) {
            ForEach(quantityTypes, id: \.self) { quantityType in
                Text(quantityType.hk_quantitytype ?? "").tag(quantityType as Quantitytype?)
            }
        }
        .onChange(of: currentLog.log2quantitytype, perform: { (value) in
                                    pickerChanged()

        })
    }
    func pickerChanged() {
        try? moc.save()
    }
}

