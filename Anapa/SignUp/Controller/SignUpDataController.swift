//
//  SignUpDataController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 21.01.2023.
//

import UIKit
import Toast_Swift
import PromiseKit
import CoreLocation
import SDWebImage

class SignUpDataController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var firstNameView: UIView!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var patronymicView: UIView!
    @IBOutlet weak var patronymicTF: UITextField!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var birthtimeView: UIView!
    @IBOutlet weak var birthtimeTF: UITextField!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationTF: UITextField!
    
    @IBOutlet weak var showTelSwitch: UISwitch!
    @IBOutlet weak var serviceCategoryView: UIView!
    @IBOutlet weak var serviceCategoryTF: UITextField!
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var siteView: UIView!
    @IBOutlet weak var siteTF: UITextField!
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var nextButton: UIButton!
    
    var userPhone = ""
    var isBusiness = false
    
    var datePicker = UIDatePicker()
    var genderPicker = UIPickerView()
    var categoryPicker = UIPickerView()
    
    var categories: [Category?] = []
    var categoryId: Int?
    var gender = 0
//    let locationManager = CLLocationManager()
    
    // for coordinate
    var latitude = 0.0
    var longitude = 0.0
    var addressText = ""
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        birthtimeTF.inputView = datePicker
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderTF.inputView = genderPicker
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        serviceCategoryTF.inputView = categoryPicker
        
        
        // set picker style
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        // set min & max date
        datePicker.minimumDate = .some(Date(timeIntervalSince1970: -2208988800))
        datePicker.maximumDate = .some(Date())
        let loc = Locale(identifier: "ru_RU")
        self.datePicker.locale = loc
        
        //set default date
        datePicker.date = Date()
        //set
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let _ = dateFormatter.string(from: datePicker.date)
        
        birthtimeTF.addTarget(self, action: #selector(editingEnded), for: .editingDidEnd)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    
        avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editAvatar)))
        photoImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editAvatar)))
        
        locationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openMap)))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
        getCategories()
    }
    
    //MARK: SETUP UI
    func setupUI(){
        spinner.stopAnimating()
        
        avatar.setOval()
        avatar.greenBorder()
        photoImage.setOval()
        
        avatar.sd_imageIndicator = SDWebImageActivityIndicator.gray
        avatar.sd_setImage(with: URL(string: getProfile()?.avatar ?? ""), placeholderImage: UIImage(named: "Avatar"), options: [], context: [:])
        
        firstNameView.addSmallRadius()
        lastNameView.addSmallRadius()
        patronymicView.addSmallRadius()
        genderView.addSmallRadius()
        birthtimeView.addSmallRadius()
        locationView.addSmallRadius()
        serviceCategoryView.addSmallRadius()
        emailView.addSmallRadius()
        siteView.addSmallRadius()
        
        nextButton.addSmallRadius()
        
        if isBusiness == true {
            firstNameTF.placeholder = "Название компании"
            locationTF.placeholder = "Адрес"
            lastNameView.isHidden = true
            patronymicView.isHidden = true
            genderView.isHidden = true
            birthtimeView.isHidden = true
            backButton.setTitle("Бизнес аккаунт", for: .normal)
            serviceCategoryView.isHidden = false
            emailView.isHidden = false
            siteView.isHidden = false
        } else {
            backButton.setTitle("Личный аккаунт", for: .normal)
            serviceCategoryView.isHidden = true
            emailView.isHidden = true
            siteView.isHidden = true
        }
    }
    
    
    @IBAction func close(_ sender: UIButton){
        dismiss(animated: true)
    }
    
    //MARK: SET DATE FROM PICKER TO TEXT FIELD
    @objc func editingEnded(_ textField: UITextField) {
        //set info to textField
        if textField == birthtimeTF {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let dateString = dateFormatter.string(from: datePicker.date)
            self.birthtimeTF.text = "\(dateString)"
        }
    }
    
    
    // MARK: GET CATEGORIES
    func getCategories(){
        spinner.startAnimating()
        makeRequest(with: RSignUpModel.fetchCategories()) { [weak self] data in
            if let categories = data?.data {
                self?.categories = categories
                self?.spinner.stopAnimating()
            }
        }
    }
    
    //MARK: SIGN IN | UPDATE USER
    @IBAction func signUpUser(_ sender: UIButton) {
        
        if isBusiness {
            if firstNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                view.makeToast("Необходимо указать название")
                return
            }
            
            if serviceCategoryTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                view.makeToast("Необходимо указать категорию услуг")
                return
            }
        } else {
            if firstNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                view.makeToast("Необходимо указать имя")
                return
            }
            
            if lastNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                view.makeToast("Необходимо указать фамилию")
                return
            }
            
            if genderTF.text?.trimmingCharacters(in: .whitespaces) == "" {
                view.makeToast("Необходимо указать пол")
                return
            }
        }
        if locationTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            view.makeToast("Необходимо указать адрес")
            return
        }

        spinner.startAnimating()
        firstly{
            ProfileModel.editProfile(firstName: firstNameTF.text!, lastName: lastNameTF.text!, patronymic: patronymicTF.text!, email: emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? nil : emailTF.text!,tg: nil, isServicer: isBusiness ,gender: gender - 1, birthtime: Int(datePicker.date.timeIntervalSince1970), location: locationTF.text!, serviceCategory: categoryId, showTel: showTelSwitch.isOn, isBusiness: isBusiness, companyInfo: nil, site: siteTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? nil : siteTF.text!, experience: nil, lat: latitude, lon: longitude)
        }.done { [weak self] data in
            
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                UserDefaults.standard.set(true, forKey: "isRegistered")
                self?.view.makeToast("Регистрация завершена", point: .init(x: (self?.view.bounds.width)! / 2, y: (self?.view.bounds.height ?? 0)! - 120), title: .none, image: .none) { _ in
                    let sBoard = UIStoryboard(name: "TabBar", bundle: .main)
                    let vc = sBoard.instantiateInitialViewController()
                    vc?.modalPresentationStyle = .fullScreen
                    self?.present(vc!, animated: true)
                }
                
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
    
    //MARK: EDIT AVATAR
    @objc func editAvatar(_ sender: Any){
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // select Camera
        let camera = UIAlertAction(title: NSLocalizedString("Сделать фото", comment: ""), style: .default) { [weak self] _ in
            self?.chooseImagePicker(source: UIImagePickerController.SourceType.camera)
        }
        // select Gallery
        let photo = UIAlertAction(title: NSLocalizedString("Выбрать из галерери", comment: ""), style: .default) { [weak self] _ in
            self?.chooseImagePicker(source: UIImagePickerController.SourceType.photoLibrary)
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("Закрыть", comment: ""), style: .cancel)
        
        actionSheet.addAction(camera)
        actionSheet.addAction(photo)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true)
    }
    
    //MARK: UPLOAD AVATAR
    func changeAvatar(image: Data){
        spinner.startAnimating()
        firstly{
            ProfileModel.changeAvatar(image: image)
        }.done { [weak self] data in
            self?.spinner.stopAnimating()
            if data.message.lowercased() == "ok"{
                self?.avatar.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self?.avatar.sd_setImage(with: URL(string: data.data?.avatar ?? ""), placeholderImage: UIImage(named: "Avatar"), options: [], context: [:])
            } else {
                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            print(error.localizedDescription)
            self?.spinner.stopAnimating()
        }
    }
    
    //MARK: UNWIND
    @IBAction func unwindSignUpData(_ sender: UIStoryboardSegue){
        locationTF.text = addressText
    }
    
    //OPEN MAP
    @objc func openMap(_ sender: Any){
        let sBoard = UIStoryboard(name: "Map", bundle: .main)
        guard let controller = sBoard.instantiateViewController(withIdentifier: "selectCoordinateVC") as? SelectCoordinateController else { return }
        controller.modalPresentationStyle = .fullScreen
        controller.coordinateType = .registration
        self.presentPanModal(controller)
    }
}


//MARK: PICKERS
extension SignUpDataController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == categoryPicker {
            return categories.count
        } else {
            return Constants.gender.count
        }
    }
    
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryPicker {
            return "\(categories[row]?.name ?? "")"
        } else {
            return "\(Constants.gender[row])"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == categoryPicker {
            serviceCategoryTF.text = "\(categories[row]?.name ?? "")"
            categoryId = categories[row]?.id ?? 0
        } else {
            genderTF.text = "\(Constants.gender[row])"
            gender = row
        }
    }
}


//MARK: WORK WITH IMAGE
extension SignUpDataController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(source){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // send new avatar to server
        self.changeAvatar(image: ((info[.editedImage] as? UIImage)?.pngData())!)
        dismiss(animated: true)
    }
}
