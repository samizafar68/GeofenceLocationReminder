import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    @EnvironmentObject var locationsVM: LocationsViewModel
    @EnvironmentObject var mapVM: MapViewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.userTrackingMode = .none
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "marker")
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        DispatchQueue.main.async {
            let currentAnnotations = uiView.annotations.filter { !($0 is MKUserLocation) }
            var currentCoords = Set<String>()
            for a in currentAnnotations {
                let key = "\(a.coordinate.latitude),\(a.coordinate.longitude)"
                currentCoords.insert(key)
            }
            let desiredAnnotations = locationsVM.pois.map { poi -> MKPointAnnotation in
                return mapVM.annotation(for: poi)
            }
            var desiredCoords = Set<String>()
            for a in desiredAnnotations {
                let key = "\(a.coordinate.latitude),\(a.coordinate.longitude)"
                desiredCoords.insert(key)
            }
            for a in currentAnnotations {
                let key = "\(a.coordinate.latitude),\(a.coordinate.longitude)"
                if !desiredCoords.contains(key) {
                    uiView.removeAnnotation(a)
                }
            }
            for a in desiredAnnotations {
                let key = "\(a.coordinate.latitude),\(a.coordinate.longitude)"
                if !currentCoords.contains(key) {
                    uiView.addAnnotation(a)
                }
            }
            if mapVM.centerToUserLocation {
                if let userLoc = uiView.userLocation.location?.coordinate {
                    let region = MKCoordinateRegion(center: userLoc,
                                                    latitudinalMeters: 2000,
                                                    longitudinalMeters: 2000)
                    uiView.setRegion(region, animated: true)
                }
               // mapVM.centerToUserLocation = false
            } else {
                let hasAnnotations = !desiredAnnotations.isEmpty
                if hasAnnotations {
                    if let first = desiredAnnotations.first {
                        let currentCenter = uiView.region.center
                        let dist = CLLocation(latitude: currentCenter.latitude, longitude: currentCenter.longitude).distance(from: CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude))
                        if dist > 500 {
                            let region = MKCoordinateRegion(center: first.coordinate,
                                                            latitudinalMeters: 2000,
                                                            longitudinalMeters: 2000)
                            uiView.setRegion(region, animated: true)
                        }
                    }
                } else if let userLoc = uiView.userLocation.location?.coordinate {
                    let currentCenter = uiView.region.center
                    let dist = CLLocation(latitude: currentCenter.latitude, longitude: currentCenter.longitude).distance(from: CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude))
                    if dist > 500 {
                        let region = MKCoordinateRegion(center: userLoc,
                                                        latitudinalMeters: 2000,
                                                        longitudinalMeters: 2000)
                        uiView.setRegion(region, animated: true)
                    }
                }
            }
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            let id = "marker"
            let view: MKMarkerAnnotationView
            if let dequeued = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView {
                view = dequeued
                view.annotation = annotation
            } else {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
            }
            view.canShowCallout = true
            if let title = annotation.title ?? "" {
                switch title.lowercased() {
                case "restaurant", "cafe":
                    view.markerTintColor = .systemRed
                case "park":
                    view.markerTintColor = .systemGreen
                case "landmark":
                    view.markerTintColor = .systemBlue
                default:
                    view.markerTintColor = .systemOrange
                }
            } else {
                view.markerTintColor = .systemOrange
            }
            view.glyphImage = UIImage(systemName: "mappin.circle.fill")
            view.rightCalloutAccessoryView = UIButton(type: .contactAdd)
            return view
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                     calloutAccessoryControlTapped control: UIControl) {
            guard let annotation = view.annotation else { return }
            if let poi = parent.locationsVM.pois.first(where: {
                abs($0.coordinate.latitude - annotation.coordinate.latitude) < 0.000001 &&
                abs($0.coordinate.longitude - annotation.coordinate.longitude) < 0.000001
            }) {
                parent.mapVM.selectedPOI = poi
                parent.mapVM.showingCreateSheet = true
            }
        }
    }
}

