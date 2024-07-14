//
//  SignUpTypeController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 20.02.2023.
//

import UIKit
import Toast_Swift

class SignUpTypeController: UIViewController {
    @IBOutlet weak var personalView: UIView!
    @IBOutlet weak var personalRadio: UIImageView!
    @IBOutlet weak var personalLabel: UILabel!
    @IBOutlet weak var businessView: UIView!
    @IBOutlet weak var businessRadio: UIImageView!
    @IBOutlet weak var businessLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    var userPhone = ""
    var isBusiness: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        personalView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPersonal)))
        businessView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectBusiness)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nextButton.addRadius()
        personalView.addRadius()
        businessView.addRadius()
    }
    
    
    @objc func selectPersonal(_ sender: UIView){
        isBusiness = false
//        personalView.greenBorder()
        businessView.layer.borderWidth = 0
        personalRadio.image = UIImage(named: "RadioEnable")
        businessRadio.image = UIImage(named: "Radio")
        personalLabel.textColor = UIColor(named: "AccentColor")
        businessLabel.textColor = UIColor(named: "GreyText")
    }
    
    @objc func selectBusiness(_ sender: UIView){
        isBusiness = true
        personalView.layer.borderWidth = 0
//        businessView.greenBorder()
        personalRadio.image = UIImage(named: "Radio")
        businessRadio.image = UIImage(named: "RadioEnable")
        personalLabel.textColor = UIColor(named: "GreyText")
        businessLabel.textColor = UIColor(named: "AccentColor")
    }
    
    //MARK: SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "signUpData"{
            let destinationVC = segue.destination as! SignUpDataController
            destinationVC.userPhone = userPhone
            destinationVC.isBusiness = isBusiness!
        }
    }
    
    @IBAction func goSignUpData(_ sender: UIButton){
        if isBusiness == nil {
            view.makeToast("Выберите тип аккаунта")
            return
        }
        performSegue(withIdentifier: "signUpData", sender: nil)
    }
}
