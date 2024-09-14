import SwiftUI
import UserNotifications

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
    @State private var isNotificationAuthorized = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isNotificationAuthorized {
                    ContentView()
                } else {
                    NotificationPermissionView(isAuthorized: $isNotificationAuthorized)
                }
            }
            .onAppear {
                checkNotificationAuthorization()
            }
        }
    }

    private func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    self.isNotificationAuthorized = true
                case .denied, .notDetermined:
                    self.isNotificationAuthorized = false
                @unknown default:
                    self.isNotificationAuthorized = false
                }
            }
        }
    }
}

struct NotificationPermissionView: View {
    @Binding var isAuthorized: Bool

    var body: some View {
        VStack {
            Text("Notifications are required for this app to function.")
                .padding()
            Button("Request Permission") {
                requestNotificationPermission()
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
        }
    }
}
