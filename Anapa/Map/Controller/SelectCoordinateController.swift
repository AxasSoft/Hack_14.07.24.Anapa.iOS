//
//  SelectCoordinateController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 22.09.2023.
//

import UIKit
import MapKit
import PanModal

class SelectCoordinateController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mapPin: UIImageView!
    
    var coordinateType: Constants.coordinateSelector? // 0 - registration, 1 - edit profile,  2 - ADS, 3 - events
    var locationType: Constants.LocationType?
    
    @IBOutlet weak var confirmButton: UIButton!
    var latitude = 0.0
    var longitude = 0.0
    var addressText = ""
    
    var locationManager: CLLocationManager?
    
    //var hospitalId = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse  {
            locationManager!.startUpdatingLocation()
        } else {
            locationManager!.requestWhenInUseAuthorization()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupView()
    }
    
    func setupView() {
        confirmButton.addRadius()
        
        switch locationType {
        case .currentСoordinates, .none:
            mapPin.isHidden = false
        case .orderCoordinates:
            mapPin.isHidden = true
        }
    }
    
    
    
    //MARK: SET TO TEXT
    func setLocationText(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude:longitude), completionHandler: {(placemarks, error)->Void in

            if (error != nil) {
                print("Не удалось получить геопозицию " + (error?.localizedDescription)!)
                return
            }

            if (placemarks?.count)! > 0 {
                let pm = placemarks?[0]
                self.displayLocationInfo(pm)
                self.latitude = latitude
                self.longitude = longitude
            } else {
                print("Не удалось получить геопозициюr")
            }
        })
    }
    
    //MARK: SET COORDINATE PIN
    func centerCoordinatePoint(mapView: MKMapView) {
        let annotations = MKPointAnnotation()
        annotations.title = "ME"
        
        let coordinate = CLLocationCoordinate2D(latitude: mapView.centerCoordinate.latitude, longitude:  mapView.centerCoordinate.longitude)
        annotations.coordinate = coordinate
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
//        mapView.addAnnotation(annotations)
    }
    
    //MARK: SET TEXT TO USER
    func displayLocationInfo(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            locationManager?.stopUpdatingLocation()
            let zip = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let thoroughfare = (containsPlacemark.thoroughfare != nil) ? containsPlacemark.thoroughfare : ""
            let subThoroughfare = (containsPlacemark.subThoroughfare != nil) ? containsPlacemark.subThoroughfare : ""
            
            locationLabel.text = (locality ?? "") + ", " + (thoroughfare ?? "") + " " + (subThoroughfare ?? "")
            addressText = locationLabel.text ?? ""
        }
    }
    
    //MARK: SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "coordinateToRegistration" {
            let destinationVC = segue.destination as! SignUpDataController
            destinationVC.latitude = latitude
            destinationVC.longitude = longitude
            destinationVC.addressText = addressText
        } else if segue.identifier == "coordinateToEditProfile" {
            let destinationVC = segue.destination as! EditProfileController
            destinationVC.latitude = latitude
            destinationVC.longitude = longitude
            destinationVC.addressText = addressText
        } else if segue.identifier == "coordinateToOrder" {
            let destinationVC = segue.destination as! CreateAndEditOrderController
            destinationVC.latitude = latitude
            destinationVC.longitude = longitude
            destinationVC.addressText = addressText
        } else if segue.identifier == "coordinateToEvent" {
            let destinationVC = segue.destination as! CreateEventController
            destinationVC.latitude = latitude
            destinationVC.longitude = longitude
            destinationVC.addressText = addressText
        }
    }

    @IBAction func returnData(_ sender: UIButton) {
        switch coordinateType{
        case .registration:
            performSegue(withIdentifier: "coordinateToRegistration", sender: nil)
        case .editProfile:
            performSegue(withIdentifier: "coordinateToEditProfile", sender: nil)
        case .order:
            performSegue(withIdentifier: "coordinateToOrder", sender: nil)
        case .event:
            performSegue(withIdentifier: "coordinateToEvent", sender: nil)
        case .none:
            dismiss(animated: true)
        }
    }
}

//MARK: - PanModalPresentable
extension SelectCoordinateController: PanModalPresentable {
    
    var shortFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(40)
    }
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var showDragIndicator: Bool {
        true
    }
}

extension SelectCoordinateController: MKMapViewDelegate {
    //MARK: WIILL AND DID
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        switch locationType {
        case .currentСoordinates, .none:
            setLocationText(latitude: mapView.centerCoordinate.latitude, 
                            longitude: mapView.centerCoordinate.longitude
            )
        case .orderCoordinates:
            break
        }
    }
}

extension SelectCoordinateController: CLLocationManagerDelegate {
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("NotDetermined")
        case .restricted:
            print("Restricted")
        case .denied:
            print("Denied")
        case .authorizedAlways:
            print("AuthorizedAlways")
        case .authorizedWhenInUse:
            print("AuthorizedWhenInUse")
            locationManager!.startUpdatingLocation()
        @unknown default:
            locationManager!.startUpdatingLocation()
        }
    }
    
    // MARK: LOCATION MANAGER
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last!
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, 
                                                  latitudinalMeters: 500,
                                                  longitudinalMeters: 500
        )
        let coordinateOrder = CLLocation(latitude: latitude, longitude: longitude)
        let orderRegion = MKCoordinateRegion(center: coordinateOrder.coordinate, 
                                             latitudinalMeters: 500,
                                             longitudinalMeters: 500
        )
        switch locationType {
        case .currentСoordinates, .none:
            mapView.setRegion(coordinateRegion, animated: false)
            setLocationText(latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
            )
        case .orderCoordinates:
            mapView.setRegion(orderRegion, animated: false)
            setLocationText(latitude: latitude, longitude: longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinateOrder.coordinate
            mapView.addAnnotation(annotation)
        }
        
        locationManager?.stopUpdatingLocation()
        locationManager = nil
        mapView.reloadInputViews()
    }
}

