//
//  MapController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 15.09.2023.
//

import UIKit
import MapKit
import PromiseKit
import Toast_Swift
import SDWebImage

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var infoMap: MKMapView!
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var businessButton: UIButton!
    @IBOutlet weak var eventsButton: UIButton!
    
    @IBOutlet weak var infoViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLastVisit: UILabel!
    var selectUser: Profile?
    
    
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var ownerAvatar: UIImageView!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var firstMemberAvatar: UIImageView!
    @IBOutlet weak var secondMemeberAvatar: UIImageView!
    @IBOutlet weak var thirdMemberAvatar: UIImageView!
    @IBOutlet weak var membersCount: UILabel!
    var selectEvent: Event?
    
    
    var events: [Event?] = []
    var users: [Profile?] = []
    
    var userPage = 1
    
    var selectedBlock = 1
    
    var categoryIds: [Int?] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse  {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        userButton.setTitleColor(UIColor.white, for: .normal)
        userButton.backgroundColor = UIColor(named: "AccentColor")
        
        //hide info view
        UIView.animate(withDuration: 0.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.infoViewBottomConstraint.constant = -350
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        userView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showUser)))
        eventView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showEvent)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        centerButton.addRadius()
        filterButton.addRadius()
        spinner.stopAnimating()
        
        userButton.addRadius()
        businessButton.addRadius()
        eventsButton.addRadius()
        
        userView.addRadius()
        eventView.addRadius()
        
        userAvatar.setOval()
        ownerAvatar.setOval()
        firstMemberAvatar.setOval()
        secondMemeberAvatar.setOval()
        thirdMemberAvatar.setOval()
        
    }
    
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
            locationManager.startUpdatingLocation()
        @unknown default:
            locationManager.startUpdatingLocation()
        }
    }
    
    
    //MARK: CHANGE TARGET
    @IBAction func changeDataOnMap(_ sender: UIButton){
        userButton.setTitleColor(UIColor.black, for: .normal)
        userButton.backgroundColor = UIColor.white
        businessButton.setTitleColor(UIColor.black, for: .normal)
        businessButton.backgroundColor = UIColor.white
        eventsButton.setTitleColor(UIColor.black, for: .normal)
        eventsButton.backgroundColor = UIColor.white
        if sender == userButton {
            userButton.setTitleColor(UIColor.white, for: .normal)
            userButton.backgroundColor = UIColor(named: "AccentColor")
            filterButton.isHidden = false
            users = []
            userPage = 1
            selectedBlock = 1
            getUser(isBusiness: false)
        } else if sender == businessButton {
            businessButton.setTitleColor(UIColor.white, for: .normal)
            businessButton.backgroundColor = UIColor(named: "AccentColor")
            filterButton.isHidden = false
            users = []
            userPage = 1
            selectedBlock = 2
            getUser(isBusiness: true)
        } else {
            eventsButton.setTitleColor(UIColor.white, for: .normal)
            eventsButton.backgroundColor = UIColor(named: "AccentColor")
            filterButton.isHidden = true
            selectedBlock = 3
            getEvents()
            
        }
    }
    
    @IBAction func unwindMap(_ sender: UIStoryboardSegue){
        //map filter category
        if let data = UserDefaults.standard.value(forKey:"mapFilterCategory") as? Data {
            if data.count > 0 {
                let selectedСategories = try! PropertyListDecoder().decode(Array<Category>.self, from: data)
                for category in selectedСategories {
                    categoryIds.append(category.id)
                }
            }
        }
        userPage = 1
        users = []
        events = []
        switch selectedBlock{
        case 1:
            getUser(isBusiness: false)
        case 2:
            getUser(isBusiness: true)
        case 3:
            getEvents()
        default:
            break
        }
        
    }
    
    
    //MARK: SHOW USER
    @objc func showUser(_ sender: Any){
        let sBoard = UIStoryboard(name: "Profile", bundle: .main)
        let vc = sBoard.instantiateViewController(withIdentifier: "UserVC") as! UserController
        vc.user = selectUser
        vc.userId = selectUser?.id
        show(vc, sender: nil)
    }
    
    //MARK: SHOW EVENT
    @objc func showEvent(_ sender: Any){
        let sBoard = UIStoryboard(name: "Events", bundle: .main)
        let vc = sBoard.instantiateViewController(withIdentifier: "EventVC") as! OneEventController
        vc.event = selectEvent
        show(vc, sender: nil)
    }
    
    
    //MARK: GET EVENTS
    func getEvents(){
        userView.isHidden = true
        eventView.isHidden = false
        //hide userView
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.infoViewBottomConstraint.constant = -350
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        spinner.startAnimating()
        firstly{
            EventsModel.getEvents(page: nil, profileIdEvents: nil, lat: infoMap.centerCoordinate.latitude, lon: infoMap.centerCoordinate.longitude, distance: nil)
        }.done { [weak self] data in
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.events = data.data
                
                for annotation in self?.infoMap.annotations ?? [] {
                    if annotation.title != (self?.getProfile().firstName ?? "") + " " + (self?.getProfile().lastName ?? "") {
                        self?.infoMap.removeAnnotation(annotation)
                    }
                }
                
                if self?.events.count == 0 {
                    self?.view.makeToast( "Ближайших событий не найдено")
                } else {
                    for event in self?.events ?? [] {
                        let annotations = MyPointAnnotation()
                        annotations.title = event?.name
                        annotations.pinTintColor = UIColor(named: "AccentColor")
                        
                        
                        let coordinate = CLLocationCoordinate2D(latitude: event?.lat ?? 0, longitude:  event?.lon ?? 0)
                        annotations.coordinate = coordinate
                        
                        self?.infoMap.addAnnotation(annotations)
                    }
                }
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.description)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    
    
    //MARK: GET USER
    func getUser(isBusiness: Bool){
        userView.isHidden = false
        eventView.isHidden = true
        //hide userView
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.infoViewBottomConstraint.constant = -350
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        
        spinner.startAnimating()
        firstly{
            ProfileModel.searchUser(search: nil, page: userPage, isBusiness: isBusiness, distance: 10000, lat: infoMap.centerCoordinate.latitude, lon: infoMap.centerCoordinate.longitude, categoryIds: categoryIds)
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                for user in data.data {
                    self?.users.append(user)
                }
                
                for annotation in self?.infoMap.annotations ?? [] {
                    if annotation.title != (self?.getProfile().firstName ?? "") + " " + (self?.getProfile().lastName ?? "") {
                        self?.infoMap.removeAnnotation(annotation)
                    }
                }
                
                if self?.users.count == 0 {
                    self?.view.makeToast( "Пользователей рядом не найдено, попробуйте изменить параметры поиска")
                } else {
                    for user in self?.users ?? [] {
                        let annotations = MyPointAnnotation()
                        annotations.title = user?.firstName
                        annotations.pinTintColor = UIColor(named: "AccentColor")
                        
                        
                        let coordinate = CLLocationCoordinate2D(latitude: user?.lat ?? 0, longitude:  user?.lon ?? 0)
                        annotations.coordinate = coordinate
                        
                        self?.infoMap.addAnnotation(annotations)
                    }
                    if data.meta?.paginator?.hasNext == true {
                        self?.userPage += 1
                        self?.getUser(isBusiness: isBusiness)
                    }
                }
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    
    
    //MARK: LOCATION MANAGER
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.first!
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        infoMap.setRegion(coordinateRegion, animated: false)
        locationManager.stopUpdatingLocation()
        setPointOnMap(mapView: infoMap)
        
        switch selectedBlock{
        case 1:
            getUser(isBusiness: false)
        case 2:
            getUser(isBusiness: true)
        case 3:
            getEvents()
        default:
            break
        }
    }
    
    
    @IBAction func centered(_ sender: UIButton){
        locationManager.startUpdatingLocation()
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        //        getEvents(lat: mapView.centerCoordinate.latitude, lon: mapView.centerCoordinate.longitude, distance: mapView.cameraZoomRange.maxCenterCoordinateDistance.magnitude * 3, mapView: mapView)
    }
    
    
    //MARK: SET COORDINATE PIN
    func setPointOnMap(mapView: MKMapView) {
        let avatar = UIImageView()
        avatar.sd_setImage(with: URL(string: getProfile().avatar ?? ""), placeholderImage: UIImage(named: "Avatar"))
        let annotations = MyPointAnnotation()
        annotations.title = (getProfile().firstName ?? "") + " " + (getProfile().lastName ?? "")
        //        annotations.pinTintColor = .black
        let coordinate = CLLocationCoordinate2D(latitude: mapView.centerCoordinate.latitude, longitude:  mapView.centerCoordinate.longitude)
        annotations.coordinate = coordinate
        for annotation in mapView.annotations {
            if annotation.title == (getProfile().firstName ?? "") + " " + (getProfile().lastName ?? "") {
                mapView.removeAnnotation(annotation)
            }
        }
        mapView.addAnnotation(annotations)
    }
    
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Failed to initialize GPS: ", error.description)
    }
    
    //MARK: FOR COLOR PIN
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        } else {
            annotationView?.annotation = annotation
        }
        if let annotation = annotation as? MyPointAnnotation {
            annotationView?.markerTintColor = annotation.pinTintColor
        }
        return annotationView
    }
    
    
    //MARK: TAP ON  PIN
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if selectedBlock == 3 {
            for event in events {
                
                if view.annotation!.coordinate.latitude == Double(event?.lat ?? 0) &&
                    view.annotation!.coordinate.longitude == Double(event?.lon ?? 0){
                    
                    selectEvent = event
                    
                    ownerName.text = (event?.user?.firstName ?? "") + " " + (event?.user?.lastName ?? "")
                    ownerAvatar.sd_setImage(with: URL(string: event?.user?.avatar ?? ""), placeholderImage: UIImage(named: "Avatar"))
                    
                    name.text = event?.name ?? ""
                    startDate.text = event?.started?.toDayAndHour
                    eventDescription.text = event?.description ?? ""
                    
                    if (event?.members.count ?? 0) >= 3 {
                        firstMemberAvatar.sd_setImage(with: URL(string: event?.members[0]?.user?.avatar ?? ""), placeholderImage: UIImage(named: "Avatar"))
                        secondMemeberAvatar.sd_setImage(with: URL(string: event?.members[1]?.user?.avatar ?? ""), placeholderImage: UIImage(named: "Avatar"))
                        thirdMemberAvatar.sd_setImage(with: URL(string: event?.members[2]?.user?.avatar ?? ""), placeholderImage: UIImage(named: "Avatar"))
                        firstMemberAvatar.isHidden = false
                        secondMemeberAvatar.isHidden = false
                        thirdMemberAvatar.isHidden = false
                    } else if (event?.members.count ?? 0) == 2 {
                        firstMemberAvatar.sd_setImage(with: URL(string: event?.members[0]?.user?.avatar ?? ""), placeholderImage: UIImage(named: "Avatar"))
                        secondMemeberAvatar.sd_setImage(with: URL(string: event?.members[1]?.user?.avatar ?? ""), placeholderImage: UIImage(named: "Avatar"))
                        firstMemberAvatar.isHidden = false
                        secondMemeberAvatar.isHidden = false
                        thirdMemberAvatar.isHidden = true
                    } else if (event?.members.count ?? 0)  == 1 {
                        firstMemberAvatar.sd_setImage(with: URL(string: event?.members[0]?.user?.avatar ?? ""), placeholderImage: UIImage(named: "Avatar"))
                        firstMemberAvatar.isHidden = false
                        secondMemeberAvatar.isHidden = true
                        thirdMemberAvatar.isHidden = true
                    } else {
                        firstMemberAvatar.isHidden = true
                        secondMemeberAvatar.isHidden = true
                        thirdMemberAvatar.isHidden = true
                    }
                    
                    membersCount.text = EventsModel.memberHumanCounter(count: event?.members.count ?? 0)
                }
            }
        } else {
            for user in users {
                if view.annotation!.coordinate.latitude == Double(user?.lat ?? 0) &&
                    view.annotation!.coordinate.longitude == Double(user?.lon ?? 0){
                    
                    selectUser = user
                    userAvatar.sd_setImage(with: URL(string: user?.avatar ?? ""), placeholderImage: UIImage(named: "Avatar"))
                    userName.text = (user?.firstName ?? "") + " " + (user?.lastName ?? "")
                    userLastVisit.text = user?.lastVisitedHuman
                }
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.infoViewBottomConstraint.constant = 20
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.infoViewBottomConstraint.constant = -350
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
}

//MARK: FOR COLOR PIN
class MyPointAnnotation : MKPointAnnotation {
    var pinTintColor: UIColor?
}
