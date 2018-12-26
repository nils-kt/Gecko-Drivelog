//
//  FirstViewController.swift
//  GeckoDrivelog
//
//  Created by Nils Kleinert on 23.12.18.
//  Copyright © 2018 Nils Kleinert. All rights reserved.
//

import UIKit
import MapKit
import NotificationBannerSwift


class DriveViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var DriveBeginButton: UIBarButtonItem!
    @IBOutlet weak var Map: MKMapView!
    @IBOutlet weak var StatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils.locationManager.requestAlwaysAuthorization()
        Utils.locationManager.allowsBackgroundLocationUpdates = true


        if !CLLocationManager.locationServicesEnabled() {
            let alert = UIAlertController(title: "Kein GPS-Signal", message: "Die App hat keinen Zugriff auf das GPS-Signal!", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
        } else {
            Utils.locationManager.startUpdatingLocation()
            Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyLine = overlay
        let polyLineRenderer = MKPolylineRenderer(overlay: polyLine)
        polyLineRenderer.strokeColor = UIColor.red.withAlphaComponent(0.5)
        polyLineRenderer.lineWidth = 3.0
        polyLineRenderer.alpha = 0.5
        return polyLineRenderer
    }
    
    @objc func updateTimer() {
        if Utils.locationManager.allowsBackgroundLocationUpdates && Utils.isDriving {
            Utils.locationManager.startUpdatingLocation()
            guard let locValue: CLLocationCoordinate2D = Utils.locationManager.location?.coordinate else { return }
            Map.setRegion(MKCoordinateRegion(center: locValue, latitudinalMeters: 75, longitudinalMeters: 75), animated: true)
            
            Utils.locations.append(locValue)
            //NSLog("Adde: %f %f -> Count: %i", locValue.latitude, locValue.longitude, locations.count)
            self.Map.delegate = self

            let polyline = MKPolyline(coordinates: &Utils.locations, count: Utils.locations.count)
            Map.addOverlay(mapView(Map, rendererFor: polyline).overlay)
            
            if Utils.locations.count >= 2 {
                let start = CLLocation(latitude: Utils.locations[Utils.locations.count - 1].latitude, longitude: Utils.locations[Utils.locations.count - 1].longitude)
                let end = CLLocation(latitude: Utils.locations[Utils.locations.count - 2].latitude, longitude: Utils.locations[Utils.locations.count - 2].longitude)
                let distanceInMeters = end.distance(from: start)

                Utils.drivenMeters = Utils.drivenMeters + distanceInMeters

                StatusLabel.text = "Kilometer: \(Double(String(format: "%.3f", Utils.drivenMeters / 1000)) ?? 0) - Fahrt: \(Utils.driveName)"
            }
        }
    }
    
    @IBAction func DriveBeginButtonClicked(_ sender: UIBarButtonItem) {
        if Utils.isDriving {
            
            let alert = UIAlertController(title: "Fahrt beenden?", message: "Möchtest du die Fahrt wirklich beenden?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Nein", style: .default, handler: { _ in
                Utils.isDriving = true
            }))
            alert.addAction(UIAlertAction(title: "Ja", style: .default, handler: { _ in
                let tvc =  TableViewController()
                tvc.InsertHistory(locations: Utils.locations, meters: Utils.drivenMeters, title: Utils.driveName)
                self.StatusLabel.text = "Gefahrene Kilometer: 0.000"
                self.DriveBeginButton.title = "Fahrt beginnen"
                NotificationBanner(title: Utils.driveName, subtitle: "Fahrt beendet und gespeichert!", style: .success).show(on: self)
                Utils.isDriving = false
                Utils.locations.removeAll()
                Utils.drivenMeters = 0.0
                self.Map.removeOverlays(self.Map.overlays)
                self.StatusLabel.text = "Kilometer: 0.000 Fahrt: Keine"
            }))
            self.present(alert, animated: true, completion: nil)
            
        } else {
           
            let saveAlert = UIAlertController(title: "Name der Fahrt", message: "Unter welchem Namen soll die Fahrt gespeichert werden?", preferredStyle: .alert)
            
            saveAlert.addTextField( configurationHandler: { (textField) in
                textField.text = "Anfahrt Kundennummer: "
            })
            
            saveAlert.addAction(UIAlertAction(title: "Fahrt beginnen", style: .default, handler: { _ in
                let textField = saveAlert.textFields?.first
                Utils.locations.removeAll()
                
                guard let locValue: CLLocationCoordinate2D = Utils.locationManager.location?.coordinate else { return }
                self.Map.setCenter(locValue, animated: true)
                self.Map.setRegion(MKCoordinateRegion(center: locValue, latitudinalMeters: 75, longitudinalMeters: 75), animated: true)
                self.DriveBeginButton.title = "Fahrt beenden"
                Utils.isDriving = true
                Utils.driveName = textField?.text ?? "Unbekannt" as String
                self.StatusLabel.text = "Fahrt zu: \(Utils.driveName)"
                NotificationBanner(title: Utils.driveName, subtitle: "Fahrt wird aufgezeichnet!", style: .info).show(on: self)
            }))
            self.present(saveAlert, animated: true, completion: nil)
        }
    }
}
