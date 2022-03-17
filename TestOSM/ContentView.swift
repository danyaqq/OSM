//
//  ContentView.swift
//  TestOSM
//
//  Created by Даня on 17.03.2022.
//

import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
        MapView()
            .ignoresSafeArea()
    }
}

struct MapView: UIViewRepresentable {
    @ObservedObject var locationManager = LocationManager()
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.setRegion(MKCoordinateRegion.init(center: .init(latitude: 54.18, longitude: 45.17), latitudinalMeters: 10000, longitudinalMeters: 10000), animated: true)
        map.showsUserLocation = true
        context.coordinator.addTileOverlay(mapView: map)
        
        for i in 0..<3 {
            let annotation = MKPointAnnotation()
            annotation.coordinate = .init(latitude: CGFloat(54.1812 + CGFloat(0.01 * CGFloat(i))), longitude: CGFloat(45.17 + CGFloat(0.01 * CGFloat(i))))
            map.addAnnotation(annotation)
        }
        
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return MapView.Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var tileRenderer: MKTileOverlayRenderer?
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKTileOverlayRenderer {
                return tileRenderer!
            } else if overlay is MKPolyline {
                let overlay = MKPolylineRenderer(overlay: overlay)
                overlay.strokeColor = UIColor.green
                overlay.lineWidth = 4
                return overlay
            }
            return tileRenderer!
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if view.annotation is MKUserLocation == false {
                guard let destination = view.annotation?.coordinate else {
                    return
                }
                createRoute(mapView, destination: destination)
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation == false {
                let view = MKAnnotationView()
                view.backgroundColor = .black
                view.frame = .init(x: 0, y: 0, width: 16, height: 16)
                view.layer.cornerRadius = 8
                return view
            } else {
                
                let circle = UIView()
                circle.frame = .init(x: 0, y: 0, width: 20, height: 20)
                circle.layer.cornerRadius = 10
                circle.backgroundColor = .blue
                
                let view = MKAnnotationView()
                view.backgroundColor = .white
                view.frame = .init(x: 0, y: 0, width: 28, height: 28)
                view.layer.cornerRadius = 14
                circle.center = view.center
                view.addSubview(circle)
                return view
            }
        }
        
        func addTileOverlay(mapView: MKMapView) {
            let overlay = MKTileOverlay(urlTemplate: "https://map.madskill.ru/osm/{z}/{x}/{y}.png/")
            overlay.canReplaceMapContent = true
            tileRenderer = MKTileOverlayRenderer(tileOverlay: overlay)
            mapView.addOverlay(overlay, level: .aboveLabels)
        }
        
        func createRoute(_ mapView: MKMapView, destination: CLLocationCoordinate2D) {
            // Remove all overlays
            for overlay in mapView.overlays {
                if overlay is MKTileOverlay == false {
                    mapView.removeOverlay(overlay)
                }
            }
            
            
            let destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: destination))
            
            let request = MKDirections.Request()
            request.source = .forCurrentLocation()
            request.destination = destinationItem
            request.transportType = .automobile
            
            let direction = MKDirections(request: request)
            direction.calculate { response, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                guard let route = response?.routes.first else {
                    return
                }
                
                mapView.addOverlay(route.polyline, level: .aboveLabels)
                mapView.setRegion(.init(route.polyline.boundingMapRect), animated: true)
            }
        }
    }
    
    
}
