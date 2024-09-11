import Foundation
import UserNotifications

class AlarmManager: ObservableObject {
    @Published var alarms: [Alarm] = []
    @Published var isToggling = false

    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
        scheduleAlarm(alarm)
    }

    func toggleAlarm(_ alarm: Alarm) {
        isToggling = true
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            DispatchQueue.global(qos: .userInitiated).async {
                // Calculate timeDifferenceSeconds for comparison with lockTime
                let timeDifferenceSeconds = calculateTimeDifferenceSeconds(alarm)

                DispatchQueue.main.async {
                    if timeDifferenceSeconds > 0 && timeDifferenceSeconds < alarm.lockTime && alarm.isEnabled {
                        // Don't allow turning off the alarm if it's within the lock time
                        self.isToggling = false
                        self.objectWillChange.send()
                        return
                    }

                    self.alarms[index].isEnabled.toggle()
                    if self.alarms[index].isEnabled {
                        self.scheduleAlarm(self.alarms[index])
                    } else {
                        self.cancelAlarm(self.alarms[index])
                    }
                    self.isToggling = false
                    self.objectWillChange.send()
                }
            }
        }
    }

    private func scheduleAlarm(_ alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "Alarm"
        content.body = "Wake up!"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("ultra_loud_alarm.wav"))

        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.hour, .minute], from: alarm.time)
        dateComponents.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    private func cancelAlarm(_ alarm: Alarm) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
    }

    func handleAlarmFired(alarmId: UUID) {
        if let index = alarms.firstIndex(where: { $0.id == alarmId }) {
            alarms[index].isEnabled = false
            scheduleWakeUpCheck(alarm: alarms[index])
        }
    }

    private func scheduleWakeUpCheck(alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "Wake-up Check"
        content.body = "Are you awake? Tap to confirm."
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: alarm.wakeUpCheckDelay, repeats: false)
        let request = UNNotificationRequest(
            identifier: "wakeUpCheck_\(alarm.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)

        // Schedule alarm repeat if wake-up check is not confirmed
        // (wake-up check delay + 1 minute for confirmation)
        DispatchQueue.main.asyncAfter(deadline: .now() + alarm.wakeUpCheckDelay + 60) {
            self.checkWakeUpConfirmation(alarm: alarm)
        }
    }

    private func checkWakeUpConfirmation(alarm: Alarm) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            if requests.contains(where: { $0.identifier == "wakeUpCheck_\(alarm.id.uuidString)" }) {
                // Wake-up check not confirmed, repeat alarm
                self.repeatAlarm(alarm: alarm)
            } else {
                // Wake-up check confirmed, re-enable the alarm
                if let index = self.alarms.firstIndex(where: { $0.id == alarm.id }) {
                    self.alarms[index].isEnabled = true
                }
            }
        }
    }

    private func repeatAlarm(alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "Alarm"
        content.body = "Wake up!"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("ultra_loud_alarm.wav"))

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "repeat_\(alarm.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func duplicateAlarm(_ alarm: Alarm) {
        let trimmedLabel = alarm.label.trimmingCharacters(in: .whitespacesAndNewlines)
        let newLabel = trimmedLabel.isEmpty ? "" : "\(trimmedLabel) (Copy)"
        let newAlarm = Alarm(
            time: alarm.time,
            isEnabled: false,
            label: newLabel,
            lockTime: alarm.lockTime,
            wakeUpCheckDelay: alarm.wakeUpCheckDelay
        )
        addAlarm(newAlarm)
    }

    func deleteAlarm(_ alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            // Calculate timeDifferenceSeconds for comparison with lockTime
            let timeDifferenceSeconds = calculateTimeDifferenceSeconds(alarm)

            if timeDifferenceSeconds > 0 && timeDifferenceSeconds < alarm.lockTime && alarm.isEnabled {
                // Don't allow deleting the alarm if it's within the lock time
                // TODO: show error
                return
            }

            cancelAlarm(alarms[index])
            alarms.remove(at: index)
        }
    }

    private func calculateTimeDifferenceSeconds(_ alarm: Alarm) -> TimeInterval {
        let calendar = Calendar.current
        let currentTime = calendar.dateComponents([.hour, .minute], from: Date())
        let alarmTime = calendar.dateComponents([.hour, .minute], from: alarm.time)

        // Calculate time difference in minutes
        let currentMinutes = currentTime.hour! * 60 + currentTime.minute!
        let alarmMinutes = alarmTime.hour! * 60 + alarmTime.minute!
        var timeDifference = alarmMinutes - currentMinutes

        // Adjust for cases where the alarm is set for the next day
        if timeDifference < 0 {
            timeDifference += 24 * 60
        }

        // Convert timeDifference to seconds
        return TimeInterval(timeDifference * 60)
    }
}
