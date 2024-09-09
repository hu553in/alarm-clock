import SwiftUI

struct AlarmRow: View {
    @ObservedObject var alarm: Alarm
    @ObservedObject var alarmManager: AlarmManager
    @State private var isEnabled: Bool
    @State private var showingDeleteConfirmation = false

    init(alarm: Alarm, alarmManager: AlarmManager) {
        self.alarm = alarm
        self.alarmManager = alarmManager
        _isEnabled = State(initialValue: alarm.isEnabled)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(timeString(from: alarm.time))
                    .font(.title)
                Text(alarm.label)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Lock time: \(Int(alarm.lockTime / 60)) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Wake-up check: \(Int(alarm.wakeUpCheckDelay / 60)) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { newValue in
                    alarmManager.toggleAlarm(alarm)
                }
            )).disabled(alarmManager.isToggling)
        }
        .contextMenu {
            Button(action: {
                alarmManager.duplicateAlarm(alarm)
            }) {
                Label("Duplicate", systemImage: "plus.square.on.square")
            }
            Button(action: {
                showingDeleteConfirmation = true
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Delete Alarm"),
                message: Text("Are you sure you want to delete this alarm?"),
                primaryButton: .destructive(Text("Delete")) {
                    alarmManager.deleteAlarm(alarm)
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
