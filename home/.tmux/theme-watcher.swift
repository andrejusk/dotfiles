import Foundation

let notification = Notification.Name("AppleInterfaceThemeChangedNotification")
let center = DistributedNotificationCenter.default()

center.addObserver(forName: notification, object: nil, queue: .main) { _ in
    print("changed")
    fflush(stdout)
}

RunLoop.main.run()
