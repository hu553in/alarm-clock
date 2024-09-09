import SwiftUI

struct AddAlarmView: View {
    @ObservedObject var alarmManager: AlarmManager
    @State private var time = Date()
    @State private var label = ""
    @State private var lockTimeMinutes: Double = 60 // Default to 60 minutes
    @State private var wakeUpCheckDelayMinutes: Double = 5 // Default to 5 minutes
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                TextField("Label", text: $label)
                VStack(alignment: .leading) {
                    Text("Lock Time: \(Int(lockTimeMinutes)) minutes")
                    Slider(value: $lockTimeMinutes, in: 0...120, step: 5)
                }
                VStack(alignment: .leading) {
                    Text("Wake-up Check Delay: \(Int(wakeUpCheckDelayMinutes)) minutes")
                    Slider(value: $wakeUpCheckDelayMinutes, in: 1...30, step: 1)
                }
            }
            .navigationTitle("Add Alarm")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save") {
                    let newAlarm = Alarm(
                        time: time,
                        label: label,
                        lockTime: lockTimeMinutes * 60,
                        wakeUpCheckDelay: wakeUpCheckDelayMinutes * 60
                    )
                    alarmManager.addAlarm(newAlarm)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
