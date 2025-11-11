import Foundation
import CoreLocation
import Combine
import UIKit

class LocationService: NSObject, ObservableObject {
    // MARK: - Properties
    static let shared = LocationService()
    private let reminder = RealmService.shared.getAllReminders()
    private let manager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastKnownLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - Permission Handling
    func requestPermissions() {
        manager.requestAlwaysAuthorization()
    }

    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Location Updates
    func startUpdating() {
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    // MARK: - Start monitoring a geofence region
    func startMonitoring(reminder: Reminder) {
        let coordinate = reminder.coordinate
        let region = CLCircularRegion(center: coordinate,
                                      radius: reminder.radius,
                                      identifier: reminder.id)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            manager.startMonitoring(for: region)
        } else {
            print("Region monitoring not available.")
        }
    }

    func stopMonitoring(reminder: Reminder) {
        let matchingRegions = manager.monitoredRegions.filter { $0.identifier == reminder.id }
        for region in matchingRegions {
            manager.stopMonitoring(for: region)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdating()
        case .denied:
            print("Location permission denied.")
        default: break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastKnownLocation = location.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let matchedReminder = reminder.first(where: { $0.id == region.identifier }) {
            NotificationService.shared.sendLocalNotification(
                title: "Geofence Reminder.!",
                body: "You're near \(matchedReminder.name)"
            )
        }
    }


    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region \(region?.identifier ?? "unknown"): \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let matchedReminder = reminder.first(where: { $0.id == region.identifier }) {
            NotificationService.shared.sendLocalNotification(
                title: "Geofence Reminder.!",
                body: "You exited \(matchedReminder.name)"
            )
        }
    }

}

