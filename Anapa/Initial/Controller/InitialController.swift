//
//  InitialController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 20.01.2023.
//

import UIKit
import PromiseKit
import YandexMobileMetrica

var selectMainTag = 0

class InitialController: UIViewController {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var stackLogo: UIStackView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var image = ["Anapa_Hint"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImage.image = UIImage(named: image.randomElement()!)
        
        if Constants.keychain["accessToken"] != nil && UserDefaults.standard.bool(forKey: "isRegistered") == true {
            updateProfile()
        } else {
            startApp()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        logo.addRadius()
    }
    
    func startApp() {
        YMMYandexMetrica.reportEvent("OPEN APP", parameters: ["User Id": "\(getProfile().id)" ], onFailure: { (error) in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        self.stackLogo.alpha = 0
        DispatchQueue.main.async {
            sleep(2)
            var sBoard = UIStoryboard(name: "SignUp", bundle: .main)
            
            if UserDefaults.standard.bool(forKey: "isRegistered"){
                
                let sBoard = UIStoryboard(name: "TabBar", bundle:nil)
                let vc = sBoard.instantiateInitialViewController()
                UIApplication.shared.delegate?.window??.rootViewController = vc
                UIApplication.shared.delegate?.window??.makeKeyAndVisible()
                self.show(vc!, sender: nil)
                return
            }
            
            let vc = sBoard.instantiateInitialViewController() as! SignUpPhoneController
            
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            vc.background = self.backgroundImage.image
            self.present(vc, animated: false, completion: nil)
        }
        UIView.animate(withDuration: 1.5, delay: 0.5, options: .curveEaseIn, animations: {
            self.stackLogo.alpha = 1
        })
    }
    
    
    // MARK: UPDATE PROFILE
    func updateProfile(){
        spinner.startAnimating()
        firstly{
            ProfileModel.fetchProfile()
        }.done { [weak self] data in
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.updateProfileData(profile: data.data!)
                self?.startApp()
            } else {
                self?.spinner.stopAnimating()
                self?.startApp()
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
            self?.startApp()
            //            self?.view.makeToast("Не удалось связаться с сервером. Проверьте подключение к сети интернет")
        }
    }
}
