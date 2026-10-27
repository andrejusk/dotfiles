import CoreWLAN
import Darwin

guard let interface = CWWiFiClient.shared().interface() else {
    exit(1)
}

let rssi = interface.rssiValue()
guard rssi < 0 else {
    exit(1)
}

print(rssi)
