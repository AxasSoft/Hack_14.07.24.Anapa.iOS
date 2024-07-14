//
//  MainContainerController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 11.10.2023.
//

import UIKit

class MainContainerController: UIViewController {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var weatherText: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var storiesButton: UIButton!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var newsButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storiesButton.setTitleColor(UIColor.white, for: .normal)
        searchButton.isHidden = false
        storiesButton.setTitleColor(UIColor.white, for: .normal)
//        storiesButton.backgroundColor = UIColor(named: "AccentColor")
        mainButton.setTitleColor(UIColor(named: "GreyColor"), for: .normal)
        newsButton.setTitleColor(UIColor(named: "GreyColor"), for: .normal)
        
        storiesButton.addRadius()
        mainButton.addRadius()
        newsButton.addRadius()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch selectMainTag{ // from initial controller
        case 0:
            updateView(storiesButton)
        case 1:
            updateView(mainButton)
        case 2:
            updateView(newsButton)
        default:
            updateView(storiesButton)
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filterOrders"{
//            let destinatinoVC = segue.destination as! RFilterAdvertsController
        }
    }
    
    
    // MARK: CHANGED CONTROLLERS
    //----------------------------------------------------------------
    private lazy var StoriesController: StoriesController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Stories", bundle: .main)
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "StoriesVC") as! StoriesController
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var MainController: MainController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "MainVC") as! MainController
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var InfoContainerController: InfoContainerController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Info", bundle: .main)
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "InfoContainerVC") as! InfoContainerController
        // Add View Controller as Child View Controller
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
    
    @IBAction func updateView(_ sender: UIButton) {
        remove(asChildViewController: StoriesController)
        remove(asChildViewController: MainController)
        remove(asChildViewController: InfoContainerController)
        // set all button inactive
        
        storiesButton.setTitleColor(UIColor(named: "GreyText"), for: .normal)
        mainButton.setTitleColor(UIColor(named: "GreyText"), for: .normal)
        newsButton.setTitleColor(UIColor(named: "GreyText"), for: .normal)
        
        if sender == storiesButton {
            searchButton.isHidden = false
            add(asChildViewController: StoriesController)
            storiesButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        } else if sender == mainButton{
            searchButton.isHidden = true
            add(asChildViewController: MainController)
            mainButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        } else {
            searchButton.isHidden = true
            add(asChildViewController: InfoContainerController)
            newsButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        }
    }
    
    //----------------------------------------------------------------
}
