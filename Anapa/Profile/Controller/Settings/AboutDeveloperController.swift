//
//  AboutDeveloperController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 21.02.2023.
//

import UIKit

class AboutDeveloperController: UIViewController {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var callWIthDeveloperView: UIView!
    @IBOutlet weak var leaveReviewView: UIView!
    @IBOutlet weak var appVersionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        logo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goAvaCoreSite)))
        callWIthDeveloperView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goAxasTelegram)))
        leaveReviewView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leaveReview)))
        
        appVersionLabel.text = "ver: " + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0")
    }
    
    
    func setupUI(){
        callWIthDeveloperView.addRadius()
        leaveReviewView.addRadius()
        callWIthDeveloperView.greyBorder()
        leaveReviewView.greyBorder()
    }
    
    
    @objc func goAvaCoreSite(_ sender: Any!){
        UIApplication.shared.open(URL(string: "https://axas.ru")!, options: [:], completionHandler: nil)
    }
    
    @objc func goAxasTelegram(){
        UIApplication.shared.open(URL(string: "https://t.me/iAXAS")!, options: [:], completionHandler: nil)
    }
    
    @objc func leaveReview(){
        UIApplication.shared.open(URL(string: "https://apple.com")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func privatePolicy(_ sender: UIButton!){
        UIApplication.shared.open(URL(string: "https://apple.com")!, options: [:], completionHandler: nil)
    }
    @IBAction func termsOfConditions(_ sender: UIButton!){
        UIApplication.shared.open(URL(string: "https://apple.com")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func close(_ sender: UIButton!){
        navigationController?.popViewController(animated: true)
    }
}
