import SwiftUI

// TODO: do we need labels?
// TODO: move wav file to assets
// TODO: add app icon
// TODO: fix project structure
// TODO: fix alarm notification
// TODO: fix wake up check
// TODO: force alarm notification to repeat until closed
// TODO: persist alarms
// TODO: edit alarm
@main
struct AlarmClockApp: App {
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
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
