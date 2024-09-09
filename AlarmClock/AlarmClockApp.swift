import SwiftUI

// TODO: fix alarm notification
// TODO: fix wake up check
// TODO: force alarm notification to repeat until closed
// TODO: persist alarms
// TODO: edit alarm
@main
struct AlarmClockApp: App {
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
