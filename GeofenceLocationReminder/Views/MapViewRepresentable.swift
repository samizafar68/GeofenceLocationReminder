import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
     // MARK: - Properties
    @EnvironmentObject var locationsVM: LocationsViewModel
    @EnvironmentObject var mapVM: MapViewModel

    // MARK: - Maps Functions
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "marker")
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        DispatchQueue.main.async {
            let existing = uiView.annotations.filter { !($0 is MKUserLocation) }
            uiView.removeAnnotations(existing)
            let annotations = self.locationsVM.pois.map { self.mapVM.annotation(for: $0) }
            uiView.addAnnotations(annotations)
            if let first = self.locationsVM.pois.first {
                let region = MKCoordinateRegion(center: first.coordinate,
                                                latitudinalMeters: 2000,
                                                longitudinalMeters: 2000)
                uiView.setRegion(region, animated: true)
            } else if let userLoc = uiView.userLocation.location?.coordinate {
                let region = MKCoordinateRegion(center: userLoc,
                                                latitudinalMeters: 2000,
                                                longitudinalMeters: 2000)
                uiView.setRegion(region, animated: true)
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
                view.canShowCallout = true
            }
            if let title = annotation.title ?? "" {
                switch title.lowercased() {
                case "restaurant","cafe": view.markerTintColor = .systemRed
                case "park": view.markerTintColor = .systemGreen
                case "landmark": view.markerTintColor = .systemBlue
                default: view.markerTintColor = .systemOrange
                }
            } else {
                view.markerTintColor = .systemRed
            }
            view.glyphImage = UIImage(systemName: "mappin.circle.fill")
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .contactAdd)
            return view
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                     calloutAccessoryControlTapped control: UIControl) {
            guard let annotation = view.annotation else { return }
            if let poi = parent.locationsVM.pois.first(where: { $0.coordinate.latitude == annotation.coordinate.latitude && $0.coordinate.longitude == annotation.coordinate.longitude }) {
                parent.mapVM.selectedPOI = poi
                parent.mapVM.showingCreateSheet = true
            }
        }
    }
}

