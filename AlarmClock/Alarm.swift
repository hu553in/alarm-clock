import Foundation

class Alarm: ObservableObject, Identifiable {
    let id = UUID()
    @Published var time: Date
    @Published var isEnabled: Bool = true
    @Published var label: String = ""
    @Published var lockTime: TimeInterval = 3600 // Default lock time of 1 hour (in seconds)
    @Published var wakeUpCheckDelay: TimeInterval = 300 // Default wake-up check delay of 5 minutes (in seconds)

    init(
        time: Date,
        isEnabled: Bool = true,
        label: String = "",
        lockTime: TimeInterval = 3600,
        wakeUpCheckDelay: TimeInterval = 300
    ) {
        self.time = time
        self.isEnabled = isEnabled
        self.label = label
        self.lockTime = lockTime
        self.wakeUpCheckDelay = wakeUpCheckDelay
    }
}
