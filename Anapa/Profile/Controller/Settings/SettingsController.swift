//
//  SettingsController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 22.01.2023.
//

import UIKit

class SettingsController: UIViewController {
    
    @IBOutlet weak var editProfileView: UIView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var aboutAutorView: UIView!
    @IBOutlet weak var aboutDeveloperView: UIView!
    @IBOutlet weak var aboutAppView: UIView!
    @IBOutlet weak var userTermsView: UIView!
    @IBOutlet weak var policyView: UIView!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var adminMailView: UIView!
    @IBOutlet weak var donationsView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        editProfileView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editProfile)))
        aboutAutorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(aboutAutor)))
        aboutDeveloperView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(aboutDeveloper)))
        aboutAppView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(aboutApp)))
        userTermsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userTerms)))
        policyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(policy)))
        adminMailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(adminMail)))
        donationsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(donations)))
        
        appVersionLabel.text = "ver: " + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        editProfileView.addSmallRadius()
        notificationView.addSmallRadius()
        aboutAppView.addSmallRadius()
        aboutAutorView.addSmallRadius()
        aboutDeveloperView.addSmallRadius()
        userTermsView.addSmallRadius()
        policyView.addSmallRadius()
        adminMailView.addSmallRadius()
        donationsView.addSmallRadius()
    }
    
    @objc func editProfile(_ sender: Any){
        performSegue(withIdentifier: "editProfile", sender: nil)
    }
    
    @objc func aboutDeveloper(_ sender: Any){
        performSegue(withIdentifier: "aboutDeveloper", sender: nil)
    }
    
    @objc func aboutApp(_ sender: Any){
        performSegue(withIdentifier: "aboutApp", sender: nil)
    }
    
    @objc func aboutAutor(_ sender: Any){
        performSegue(withIdentifier: "aboutAutor", sender: nil)
    }
    
    @objc func policy(_ sender: Any){
        UIApplication.shared.open(URL(string: "https://www.welcome-project.com/privacy-policy")!, options: [:], completionHandler: nil)
    }
    
    @objc func userTerms(_ sender: Any){
        UIApplication.shared.open(URL(string: "https://www.welcome-project.com/terms-conditions")!, options: [:], completionHandler: nil)
    }
    
    @objc func adminMail(_ sender: Any){
        UIApplication.shared.open(URL(string: "mailto:movingto.help@gmail.com")!, options: [:], completionHandler: nil)
    }
    
    @objc func donations(_ sender: Any){
        performSegue(withIdentifier: "donationsApp", sender: nil)
    }
    
    @IBAction func close(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "aboutAutor" {
            let destinationVC = segue.destination as! AppInfoController
            destinationVC.infoBlock = "about"
        } else if segue.identifier == "aboutApp" {
            let destinationVC = segue.destination as! AppInfoController
            destinationVC.infoBlock = "app"
        } else if segue.identifier == "donationsApp" {
            let destinationVC = segue.destination as! AppInfoController
            destinationVC.infoBlock = "donations"
        }
        
    }
    
    @IBAction func unwindSettings(_ sender: UIStoryboardSegue){
        
    }
}
