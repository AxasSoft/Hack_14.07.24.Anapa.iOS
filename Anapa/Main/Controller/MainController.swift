//
//  MainController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 03.02.2023.
//

import UIKit
import SDWebImage
import PromiseKit
import AppTrackingTransparency
import Toast_Swift
import CenteredCollectionView
import SwiftyMarkdown

var infoSelect = 0

class MainController: UIViewController, UITabBarDelegate {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var weatherText: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var eventsCollection: UICollectionView!
    @IBOutlet weak var saleCollection: UICollectionView!
    @IBOutlet weak var newsCollection: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var portNewsCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var allNewsButton: UIButton!
    
    
    @IBOutlet weak var hotelButton: UIButton!
    @IBOutlet weak var hotelName: UILabel!
    @IBOutlet weak var planeButton: UIButton!
    @IBOutlet weak var planeName: UILabel!
    @IBOutlet weak var trainButton: UIButton!
    @IBOutlet weak var trainName: UILabel!
    
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var dateVieww: UIView!
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var peopleCountView: UIView!
    @IBOutlet weak var peopleCountTF: UITextField!
    @IBOutlet weak var peopleName: UILabel!
    @IBOutlet weak var goView: UIView!
    
    
    
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var blur: UIVisualEffectView!
    @IBOutlet weak var modalViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var modalStoriesButton: UIButton!
    @IBOutlet weak var modalNewsButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var modalButtonsWidthConstraint: NSLayoutConstraint!
    var bottomOrTop: CGFloat = 64 {
        didSet {
            if bottomOrTop == 64 {
                blur.isHidden = true
            } else {
                blur.isHidden = false
            }
        }
    }
    
    
    var events: [Event?] = []
    var krdNews: [Info?] = []
    var newsDigest: [Info?] = []
    var lastNews: [Info?] = []
    
    var orders: [Order?] = []
    
    var selectCategory: Int?
    
    var currentCenteredPage = 0
    let cellPercentWidth: CGFloat = 0.7
    var eventCenteredCollectiont: CenteredCollectionViewFlowLayout!
    var newsCenteredCollectiont: CenteredCollectionViewFlowLayout!
    
    var selectedOrderId = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //EVENTS
        eventCenteredCollectiont = (eventsCollection.collectionViewLayout as! CenteredCollectionViewFlowLayout)  // Modify the collectionView's decelerationRate (REQUIRED STEP)
        eventsCollection.decelerationRate = UIScrollView.DecelerationRate.fast  // Assign delegate and data source
        eventsCollection.delegate = self
        eventsCollection.dataSource = self
        // Configure the required item size (REQUIRED STEP)
        eventCenteredCollectiont.itemSize = CGSize( width: view.bounds.width - 32,  height: 220)  // Configure the optional inter item spacing (OPTIONAL STEP)
        eventCenteredCollectiont.minimumLineSpacing = 8
        
        //NEWS
        newsCenteredCollectiont = (newsCollection.collectionViewLayout as! CenteredCollectionViewFlowLayout)  // Modify the collectionView's decelerationRate (REQUIRED STEP)
        newsCollection.decelerationRate = UIScrollView.DecelerationRate.fast  // Assign delegate and data source
        newsCollection.delegate = self
        newsCollection.dataSource = self
        // Configure the required item size (REQUIRED STEP)
        newsCenteredCollectiont.itemSize = CGSize( width: view.bounds.width - 32,  height: 300)  // Configure the optional inter item spacing (OPTIONAL STEP)
        newsCenteredCollectiont.minimumLineSpacing = 10
        
        
        saleCollection.delegate = self
        saleCollection.dataSource = self
        
        goView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTourism)))
        
        
        // MARK: DEEP LINK
        if (UserDefaults.standard.value(forKey: "deepLink") as? Data) != nil {
            var linkInfo: DeepLinkData?
            if let data = UserDefaults.standard.value(forKey:"deepLink") as? Data {
                if data != nil {
                    linkInfo = try! PropertyListDecoder().decode(DeepLinkData.self, from: data)
                    
                    UserDefaults.standard.set(nil, forKey: "deepLink")
                    
                    if linkInfo?.linkType == .user {
                        let sBoard = UIStoryboard(name: "Profile", bundle: .main)
                        let addVC = sBoard.instantiateViewController(withIdentifier: "UserVC") as! UserController
                        addVC.userId = linkInfo?.id
                        self.show(addVC, sender: nil)
                    } else {
                        let sBoard = UIStoryboard(name: "Info", bundle: .main)
                        let addVC = sBoard.instantiateViewController(withIdentifier: "OneInfoVC") as! OneInfoController
                        addVC.infoId = linkInfo?.id
                        self.show(addVC, sender: nil)
                    }
                }
            }
        }
        
        ATTrackingManager.requestTrackingAuthorization { (status) in
            switch status {
            case .authorized: break
            case .notDetermined:
                break
            case .restricted:
                break
            case .denied:
                break
            @unknown default:
                break
            }
        }
        avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openProfile)))
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        modalView.addGestureRecognizer(panGesture)
        
        blur.isHidden = true
        blur.alpha = 0
        modalViewHeightConstraint.constant = 80
        changeModalData(modalStoriesButton)
        modalButtonsWidthConstraint.constant = (modalView.frame.width - 32)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupUI()
        getNotification()
        getOrders()
        fetchNewsAnapa()
        getEvents()
        getWeather()
        modalStoriesButton.addRadius()
        modalNewsButton.addRadius()
        
        hotelButton.setOval()
        planeButton.setOval()
        trainButton.setOval()
        cityView.addRadius()
        peopleCountView.addRadius()
        dateVieww.addRadius()
        goView.addRadius()
    }
    
    @objc func openTourism(_ sender: Any){
        tabBarController?.selectedIndex = 4
    }
    
    @IBAction func changeTourism(_ sender: UIButton){
        hotelName.textColor = UIColor(resource: .greyText)
        planeName.textColor = UIColor(resource: .greyText)
        trainName.textColor = UIColor(resource: .greyText)
        hotelButton.tintColor = UIColor(resource: .greyText)
        hotelButton.backgroundColor = UIColor.white
        planeButton.tintColor = UIColor(resource: .greyText)
        planeButton.backgroundColor = UIColor.white
        trainButton.tintColor = UIColor(resource: .greyText)
        trainButton.backgroundColor = UIColor.white
        
        if sender == hotelButton {
            hotelName.textColor = UIColor(resource: .accent)
            hotelButton.tintColor = UIColor.white
            hotelButton.backgroundColor = UIColor(resource: .accent)
            peopleName.text = "Гости"
        } else if sender == planeButton {
            planeName.textColor = UIColor(resource: .accent)
            planeButton.tintColor = UIColor.white
            planeButton.backgroundColor = UIColor(resource: .accent)
            peopleName.text = "Пассажиры"
        } else {
            trainName.textColor = UIColor(resource: .accent)
            trainButton.tintColor = UIColor.white
            trainButton.backgroundColor = UIColor(resource: .accent)
            peopleName.text = "Пассажиры"
        }
    }
    
    
    
    //MARK: SWIPE BOTTOM MODAL
    @objc func handlePanGesture(sender: UIPanGestureRecognizer){
        var translation : CGPoint = sender.translation(in: modalView)
        var x = abs(translation.y) + 80
        let y = self.view.frame.size.height - 150
        if bottomOrTop < (view.frame.size.height / 3) {
            if translation.y > 0 {
                modalViewHeightConstraint.constant = 80 - translation.y
            } else {
                modalViewHeightConstraint.constant = 80 + abs(translation.y)
            }
            modalButtonsWidthConstraint.constant = (modalView.frame.width - 32) - (modalView.frame.width - 164 - 32) * CGFloat(x / y)
        } else {
            x = self.view.frame.size.height - 150 - abs(translation.y)
            if translation.y > 0 {
                modalViewHeightConstraint.constant = self.view.frame.size.height - 150 - translation.y
            } else {
                modalViewHeightConstraint.constant = self.view.frame.size.height - 150 + abs(translation.y)
            }
            modalButtonsWidthConstraint.constant = (modalView.frame.width - 32) - (modalView.frame.width - 164 - 32) * CGFloat(x / y)
        }
        
        blur.isHidden = false
        blur.alpha = CGFloat(x / y)

        
        if sender.state == .ended{
            if modalViewHeightConstraint.constant < (view.frame.size.height / 3) {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self.modalViewHeightConstraint.constant = 80
                    self.blur.alpha = 0
                    self.modalButtonsWidthConstraint.constant = self.modalView.frame.width - 32
                    self.view.layoutIfNeeded()
                    self.bottomOrTop = 64
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self.modalViewHeightConstraint.constant = self.view.frame.size.height - 150
                    self.blur.alpha = 1
                    self.modalButtonsWidthConstraint.constant = 164
                    self.view.layoutIfNeeded()
                    self.bottomOrTop = self.view.frame.size.height - 150
                }, completion: nil)
                
            }
        }
    }
    
    
    //MARK: GET WEATHER
    func getWeather(){
        spinner.startAnimating()
        firstly{
            MainModel.getWeather()
        }.done { [weak self] data in
            // if ok
            let currentWeather = data.current
            self?.setupWeather(weather: currentWeather)

        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
        }
    }
    
    func setupWeather(weather: CurrentWeather?) {
        weatherText.text = ""
        weatherText.text = (weather?.tempC ?? 0) > 0 ? (weatherText.text ?? "") + "+" : (weatherText.text ?? "")
        weatherText.text = (weatherText.text ?? "") + "\(weather?.tempC ?? 0)" + ", " + (weather?.condition?.text ?? "")
        weatherIcon.sd_setImage(with: URL(string: (weather?.condition?.icon ?? "").replacingOccurrences(of: "//", with: "http://")), placeholderImage: UIImage(named: "Weather"))
        weatherText.numberOfLines = 0
    }
    
    func setupUI(){
        allNewsButton.addRadius()
        modalView.topRadius()
        
        avatar.setOval()
        avatar.sd_setImage(with: URL(string: getProfile().avatar ?? ""), placeholderImage: UIImage(named: "Avatar"))
        navigationController?.navigationBar.isHidden = true
        switch Int(Int(Date().timeIntervalSince1970).toHour) ?? 12{
        case 0..<7:
            helloLabel.text = "Доброй ночи, " + (getProfile().firstName ?? "")
        case 7..<12:
            helloLabel.text = "Доброе утро, " + (getProfile().firstName ?? "")
        case 12..<18:
            helloLabel.text = "Добрый день, " + (getProfile().firstName ?? "")
        case 18...23:
            helloLabel.text = "Добрый вечер, " + (getProfile().firstName ?? "")
        default:
            helloLabel.text = "Добрый день, " + (getProfile().firstName ?? "")
        }
        
        
    }
    
    
    //MARK: OPENS
    
    @IBAction func openInfo(_ sender: UIButton) {
        infoSelect = 0
        tabBarController?.selectedIndex = 4
    }
    
    @IBAction func openNews(_ sender: UIButton) {
        let sBoard = UIStoryboard(name: "Info", bundle: .main)
        let vc = sBoard.instantiateInitialViewController()
        self.show(vc!, sender: nil)
    }
    
    @IBAction func openAds(_ sender: Any){
        infoSelect = 0
        tabBarController?.selectedIndex = 2
    }
    
    @objc func openProfile(_ sender: Any){
        let sBoard = UIStoryboard(name: "Profile", bundle: .main)
        let vc = sBoard.instantiateInitialViewController() as! ProfileController
        self.show(vc, sender: nil)
    }
    
    @IBAction func openSearch(_ sender: Any){
        let sBoard = UIStoryboard(name: "Profile", bundle: .main)
        let vc = sBoard.instantiateViewController(withIdentifier: "SearchVC") as! SearchController
        self.show(vc, sender: nil)
    }
    
    //MARK: UNWIND
    @IBAction func unwindMain(_ sender: UIStoryboardSegue) {
        DispatchQueue.main.async { [weak self] in
            sleep(UInt32(0.5))
            if self?.selectCategory != nil {
                infoSelect = (self?.selectCategory)!
                self?.tabBarController?.selectedIndex = 4
            }
        }
    }
    
    //MARK: INVITE
    @IBAction func invite(_ sender: UIButton){
        let share:[Any] = ["Присоединяйся к приложению Моя Анапа!\n\n http://91.210.168.92:99/api/v1/app/"]
        let shareController = UIActivityViewController(activityItems: share, applicationActivities: nil)
        self.present(shareController, animated: true, completion: nil)
    }
    
    
    //MARK: GET NOTIFICATION
    func getNotification(){
        firstly{
            ProfileModel.fetchNotification()
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                if data.data.count > 0 {
                    if data.data[0]?.isRead == false{
                        self?.notificationButton.setImage(UIImage(named: "NotificatoinsBlackRed"), for: .normal)
                    } else {
                        self?.notificationButton.setImage(UIImage(named: "NotificatoinsBlack"), for: .normal)
                    }
                }
            }
        }.catch{  error in
            print(error.localizedDescription)
        }
    }
    
    //MARK: GET ORDERS
    func getOrders(){
        spinner.startAnimating()
        firstly{
            OrdersModel.fetchOrders(page: 1, showMy: false)
        }.done { [weak self] data in
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.orders = data.data
                self?.saleCollection.reloadData()
                if self?.orders.count == 0 {
                    
                } else {
                    self?.saleCollection.isHidden = false
                }
                self?.saleCollection.reloadData()
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.description)
                self?.saleCollection.reloadData()
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
            self?.saleCollection.reloadData()
        }
    }
    
    // MARK: - ADDS OR REMOVES ORDER FROM FAVORITES
    func addOrRemoveToFavorites(id: Int, isFavorite: Bool, completion: @escaping (Bool) -> Void) {
        makeRequest(with: OrdersModel.addOrRemoveToFavorites(id: id, isFavorite: isFavorite)) { data in
            guard let isFavorite = data?.data?.isFavorite else { return }
            completion(isFavorite)
        }
    }
    
    //MARK: GET EVENTS
    func getEvents(){
        spinner.startAnimating()
        firstly{
            EventsModel.getEvents(page: 1, profileIdEvents: nil, lat: nil, lon: nil, distance: nil)
        }.done { [weak self] data in
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.events = data.data
                self?.eventsCollection.reloadData()
                if self?.events.count == 0 {
                    self?.eventsCollection.isHidden = true
                } else {
                    self?.eventsCollection.isHidden = false
                }
                self?.eventsCollection.reloadData()
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.description)
                self?.eventsCollection.reloadData()
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
            self?.eventsCollection.reloadData()
        }
    }
    
    //MARK: GET ANAPA NEWS
    func fetchNewsAnapa(){
        spinner.startAnimating()
        firstly{
            InfoModel.fetchInfoBlocks(category: 0, search: nil, page: nil)
        }.done { [weak self] data in
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.krdNews = data.data
                self?.newsCollection.reloadData()
                if (self?.krdNews.count ?? 0) > 3 {
                    self?.portNewsCollectionHeight.constant = 3 * 300 + 22
                } else {
                    self?.portNewsCollectionHeight.constant = CGFloat((300 * (self?.krdNews.count ?? 0)) + 20)
                }
                self?.spinner.stopAnimating()
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    
    
    
    //MARK: MODAL CONTROLLERS
    //----------------------------------------------------------------
    private lazy var storiesController: StoriesController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Stories", bundle: .main)
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "StoriesVC") as! StoriesController
        // Add View Controller as Child View Controller
        viewController.hiddenTop = true
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var infoContainerContoller: InfoContainerController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Info", bundle: .main)
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "InfoContainerVC") as! InfoContainerController
        // Add View Controller as Child View Controller
        viewController.hiddenTop = true
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    
    // MARK: Add controller
    //----------------------------------------------------------------
    
    private func add(asChildViewController viewController: UIViewController) {
        
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        containerView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    
    //MARK: Remove controller
    //----------------------------------------------------------------
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        // Notify Child View Controller
        viewController.removeFromParent()
    }
    
    //----------------------------------------------------------------
    //MARK: CHANGE MODAL DATA
    @IBAction func changeModalData(_ sender: UIButton){
        remove(asChildViewController: storiesController)
        remove(asChildViewController: infoContainerContoller)
        
        modalStoriesButton.backgroundColor = UIColor.clear
        modalNewsButton.backgroundColor = UIColor.clear
        modalStoriesButton.setTitleColor(UIColor(named: "GreyText"), for: .normal)
        modalNewsButton.setTitleColor(UIColor(named: "GreyText"), for: .normal)
        if sender == modalNewsButton {
            modalNewsButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
            add(asChildViewController: infoContainerContoller)
        } else {
            modalStoriesButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
            add(asChildViewController: storiesController)
        }
    }
}



//MARK: COLLECTION
extension MainController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == eventsCollection {
            return events.count
            //            return 5
        } else if collectionView == saleCollection {
            return orders.count
        } else {
            if krdNews.count > 3 {
                return 3
            } else {
                return krdNews.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // if eventsCollection
        if collectionView == eventsCollection {
            let mainEventCell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainEventCell", for: indexPath) as! MainEventCollectionViewCell
            mainEventCell.cover.sd_setImage(with: URL(string: events[indexPath.item]?.images[0]?.link ?? ""), placeholderImage: UIImage(named: "ImagePlaceholder"))
            mainEventCell.name.text = events[indexPath.item]?.name
            mainEventCell.date.text = events[indexPath.item]?.created?.toDay
            return mainEventCell
            
            // if eventsCollection
        } else if collectionView == saleCollection {
            let saleCell = collectionView.dequeueReusableCell(withReuseIdentifier: "saleCell", for: indexPath) as! MainSaleCollectionViewCell
            
            saleCell.cover.image = UIImage(named: "ImagePlaceholder")
            if (orders[indexPath.item]?.images.count ?? 0) > 0 {
                saleCell.cover.sd_setImage(with: URL(string: orders[indexPath.item]?.images[0]?.link ?? ""), placeholderImage: UIImage(named: "ImagePlaceholder"))
            }
            
            if let isFavorite = self.orders[indexPath.item]?.isFavorite, isFavorite {
                saleCell.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            } else {
                saleCell.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
            
            saleCell.title.text = orders[indexPath.item]?.title
            saleCell.price.text = formatCurrency(orders[indexPath.item]?.profit ?? 0)
            
            saleCell.isFavoriteDidTapClosure = {
                guard let id = self.orders[indexPath.item]?.id,
                      let isFavorite = self.orders[indexPath.item]?.isFavorite else { return }
                
                self.addOrRemoveToFavorites(id: id, isFavorite: !isFavorite) { [weak self] isFavorite in
                    self?.orders[indexPath.item]?.isFavorite = isFavorite
                    
                    switch isFavorite {
                    case true:
                        saleCell.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    case false:
                        saleCell.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    }
                }
            }
            return saleCell
            
        } else {
            let mainNewsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainNewsCell", for: indexPath) as! MainNewsCollectionViewCell
            mainNewsCell.cover.sd_setImage(with: URL(string: krdNews[indexPath.item]?.image ?? ""), placeholderImage: UIImage(resource: .anapa))
            mainNewsCell.date.text = krdNews[indexPath.item]?.created?.toDay ?? ""
            mainNewsCell.title.text = krdNews[indexPath.item]?.title
            mainNewsCell.body.attributedText = SwiftyMarkdown(string: krdNews[indexPath.row]?.body ?? "").attributedString()
            return mainNewsCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sBoard = UIStoryboard(name: "Info", bundle: .main)
        let vc = sBoard.instantiateViewController(withIdentifier: "OneInfoVC") as! OneInfoController
        vc.modalPresentationStyle = .fullScreen
        if collectionView == eventsCollection {
            if indexPath.item < events.count {
                let story = UIStoryboard(name: "Events", bundle: nil)
                let vc = story.instantiateViewController(identifier: "EventVC") as! OneEventController
                vc.event = events[indexPath.item]
                navigationController?.pushViewController(vc, animated: true)
            }
        } else  if collectionView == saleCollection {
            if indexPath.item < orders.count {
                selectedOrderId = indexPath.item
                let story = UIStoryboard(name: "Orders", bundle: nil)
                let vc = story.instantiateViewController(identifier: "orderInfoController") as! OrderInfoController
                vc.order = orders[selectedOrderId]
                vc.isChanged = false
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            vc.info = krdNews[indexPath.item]
        }
        //show(vc, sender: nil)
    }
}
