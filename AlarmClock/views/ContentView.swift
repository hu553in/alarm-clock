import SwiftUI

struct ContentView: View {
    @StateObject private var alarmManager = AlarmManager()
    @State private var showingAddAlarm = false

    var body: some View {
        NavigationView {
            Group {
                if alarmManager.alarms.isEmpty {
                    VStack {
                        Text("No alarms")
                            .font(.title)
                            .foregroundColor(.secondary)
                        Text("Tap + to create your first alarm")
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(alarmManager.alarms) { alarm in
                            AlarmRowView(alarm: alarm, alarmManager: alarmManager)
                        }
                        .onDelete(perform: deleteAlarm)
                    }
                }
            }
            .navigationTitle("Alarms")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddAlarm = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
        }
        .sheet(isPresented: $showingAddAlarm) {
            AddAlarmView(alarmManager: alarmManager)
        }
    }

    private func deleteAlarm(at offsets: IndexSet) {
        for index in offsets {
            alarmManager.deleteAlarm(alarmManager.alarms[index])
        }
    }
}
