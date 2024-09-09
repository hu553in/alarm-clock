import SwiftUI

struct ContentView: View {
    @StateObject private var alarmManager = AlarmManager()
    @State private var showingAddAlarm = false

    var body: some View {
        NavigationView {
            List {
                ForEach(alarmManager.alarms) { alarm in
                    AlarmRow(alarm: alarm, alarmManager: alarmManager)
                }
                .onDelete(perform: deleteAlarm)
            }
            .navigationTitle("Alarms")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddAlarm = true }) {
                        Image(systemName: "plus")
                    }
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
