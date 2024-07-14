//
//  SignUpCodeController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 20.01.2023.
//

import UIKit
import PromiseKit
import Toast_Swift
import JMMaskTextField

class SignUpCodeController: UIViewController {
    
    @IBOutlet weak var codeTxt: OneTimeCodeTextField!
    @IBOutlet weak var repeatSenButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var userPhoneLabel: UILabel!
    var userPhone = ""
    
    //timer
    var repeatSend = false
    var timer = Timer()
    var seconds = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToHideKeyboard()
        sendCode()
        
        // Configure has to be called first
        codeTxt.configure(withSlotCount: 4, andSpacing: 16)              // Default: 6 slots, 8 spacing
        
        
        // Customisation(Optional)
        codeTxt.codeBackgroundColor = UIColor(named: "Background") ?? .gray        // Default: .secondarySystemBackground
        codeTxt.codeTextColor = .label                                  // Default: .label
        codeTxt.codeFont = .systemFont(ofSize: 24, weight: .regular)      // Default: .system(ofSize: 24)
        codeTxt.codeMinimumScaleFactor = 0.2                            // Default: 0.8
        
        codeTxt.codeCornerRadius = 8                                // Default: 8
        codeTxt.codeCornerCurve = .continuous                           // Default: .continuous
        
        codeTxt.codeBorderWidth = 0                                     // Default: 0
        codeTxt.codeBorderColor = .label                                // Default: .none
        
        // Allow none-numeric code
        codeTxt.oneTimeCodeDelegate.allowedCharacters = .decimalDigits  // Default: .decimalDigits
        
        //You should also specify which corresponding keyboard should be shown
        codeTxt.keyboardType = .numberPad                            // Default: .numberPad
        
        // Get entered Passcode
        codeTxt.didReceiveCode = { code in
            print(code)
            self.signIn(code: code)
        }
        
        // Clear textfield
        codeTxt.clear()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    func setupUI(){
        spinner.stopAnimating()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(sendRepeatTimer), userInfo: nil, repeats: true)
        nextButton.addRadius()
        userPhoneLabel.text = "Звонок на номер " + (JMStringMask.initWithMask("+0 (000) 000 00 00")?.maskString(userPhone) ?? "")
    }
    
    // MARK: BACK TO PHONE
    @IBAction func close(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: REPEAT SEND
    @IBAction func repeatSendCode(_ sender: Any) {
        if repeatSend {
            seconds = 60
            repeatSend = false
            sendCode()
        }
    }
    
    // timer parametres
    @objc func sendRepeatTimer(){
        seconds -= 1
        if seconds > 0{
            repeatSenButton.setTitle("Позвонить повторно через 0:\(seconds)", for: .normal)
            repeatSenButton.isEnabled = false
            repeatSenButton.alpha = 0.9
        }
        if seconds == 0 {
            repeatSend = true
            repeatSenButton.setTitle("Позвонить повторно", for: .normal)
            repeatSenButton.isEnabled = true
            repeatSenButton.alpha = 1
        }
    }
    
    //MARK: SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signUpType"{
            let destinationVC = segue.destination as! SignUpTypeController
            destinationVC.userPhone = userPhone
        }
    }
    
    // MARK: SEND CODE
    func sendCode(){
        firstly{
            RSignUpModel.fetchVerificationCode(phone: userPhone)
        }.done { [weak self] data in
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.spinner.stopAnimating()
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
            self?.view.makeToast(error.localizedDescription)
        }
    }
    
    
    // MARK: SIGN IN
    func signIn(code: String) {
        spinner.startAnimating()
        firstly{
            RSignUpModel.fetchLogin(phone: userPhone, code: code)
        }.done { [weak self] data in
            
            // if ok
            if (data.message.lowercased() == "ok") {
                do {
                    try Constants.keychain.set((data.data?.accessToken)!, key: "accessToken")
                }
                
                self?.updateProfileData(profile: (data.data?.user ?? self?.getProfile())!)
                if data.data?.user?.firstName != nil && data.data?.user?.firstName?.trimmingCharacters(in: .whitespaces) != "" {
                    UserDefaults.standard.set(true, forKey: "isRegistered")
                    let sBoard = UIStoryboard(name: "TabBar", bundle: .main)
                    let vc = sBoard.instantiateInitialViewController()
                    vc?.modalPresentationStyle = .fullScreen
                    self?.present(vc!, animated: true)
                } else {
                    self?.performSegue(withIdentifier: "signUpType", sender: nil)
                }
                self?.spinner.stopAnimating()
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast("\(data.errorDescription ?? "")")
            }
        }.catch{ error in
            self.spinner.stopAnimating()
            print(error.localizedDescription)
            return
        }
    }
}

