//
//  SignUpPhoneController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 20.01.2023.
//

import UIKit
import JMMaskTextField
import Toast_Swift

class SignUpPhoneController: UIViewController {
    
    @IBOutlet weak var logoStack: UIStackView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var content: UIStackView!
    @IBOutlet weak var phoneTF: JMMaskTextField!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    
    var background: UIImage?
    
    @IBOutlet weak var checkBoxButton: UIButton!
    var personalData = true

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImage.image = background
        addTapGestureToHideKeyboard()
        
        phoneTF.addTarget(self, action: #selector(changeSelectTF), for: .allEvents)
        content.isHidden = true
        showContent()
    }
    
    func showContent(){
        content.alpha = 0
        UIView.animate(withDuration: 1.5, delay: 1, options: .curveEaseIn, animations: {
            self.content.alpha = 1
            self.content.isHidden = false
        })
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        phoneTF.addSmallRadius()
        phoneTF.smallWhiteBorder()
        nextButton.addSmallRadius()
        nextButton.isEnabled = false
        nextButton.alpha = 0.5
        phoneTF.addLeftPadding()
        logo.addRadius()
        if phoneTF.unmaskedText.count >= 11 {
            nextButton.alpha = 1
            nextButton.isEnabled = true
        }
    }

    
    @IBAction func showPolicy(_ sender: UIButton){
        UIApplication.shared.open(URL(string: "https://krasnodar.axas.ru/krasnodar_policy.pdf")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func personalDataCheckBox(_ sender: UIButton){
        personalData = !personalData
        if personalData {
            checkBoxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        } else {
            checkBoxButton.setImage(UIImage(systemName: "square"), for: .normal)
        }
    }
    
    //MARK: SELECT TF
    @objc func changeSelectTF(_ textField: UITextField) {
        if phoneTF.unmaskedText.count >= 11 {
            nextButton.alpha = 1
            nextButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
            nextButton.alpha = 0.2
        }
    }
    
    //MARK: GET CODE
    @IBAction func getCode(_ sender: UIButton){
        if !personalData {
            view.makeToast("Необходимо принять условия обработки персональных данных")
            return
        }
        performSegue(withIdentifier: "getCode", sender: nil)
    }
    
    //MARK: START WITHOUT REGISTRATION
//    @IBAction func startWithoutRegistration(_ sender: UIButton){
//        let alertVC = UIAlertController(title: "Внимание", message: "При входе без регистрации часть функционала будет недоступна", preferredStyle: .alert)
//        let ok = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
//            UserDefaults.standard.set(false, forKey: "isRegistered")
//            let sBoard = UIStoryboard(name: "TabBar", bundle: .main)
//            let vc = sBoard.instantiateInitialViewController()
//            vc?.modalPresentationStyle = .fullScreen
//            self?.present(vc!, animated: true)
//        }
//        let cancel = UIAlertAction(title: "Нет", style: .default)
//        alertVC.addAction(ok)
//        alertVC.addAction(cancel)
//        present(alertVC, animated: true)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getCode"{
            let destinationVC = segue.destination as! SignUpCodeController
            destinationVC.userPhone = phoneTF.unmaskedText
        }
    }
    
}
