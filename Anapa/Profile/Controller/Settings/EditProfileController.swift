//
//  EditProfileController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 22.01.2023.
//

import UIKit
import Toast_Swift
import PromiseKit
import SDWebImage
import JMMaskTextField

class EditProfileController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var firstNameView: UIView!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var aboutCompanyView: UIView!
    @IBOutlet weak var aboutCompanyTV: UITextView!
    @IBOutlet weak var businessSiteView: UIView!
    @IBOutlet weak var businessSiteTF: UITextField!
    @IBOutlet weak var patronymicView: UIView!
    @IBOutlet weak var patronymicTF: UITextField!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var birthtimeView: UIView!
    @IBOutlet weak var birthtimeTF: UITextField!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var tgView: UIView!
    @IBOutlet weak var tgTF: UITextField!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var userSiteView: UIView!
    @IBOutlet weak var userSiteTF: UITextField!
    @IBOutlet weak var experienceView: UIView!
    @IBOutlet weak var experienceTV: UITextView!
    
    
    @IBOutlet weak var showTelSwitch: UISwitch!
    
    @IBOutlet weak var serviceSwitch: UISwitch!
    @IBOutlet weak var serviceCategoryView: UIView!
    @IBOutlet weak var serviceCategoryTF: UITextField!
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var exitProfileButton: UIButton!
    @IBOutlet weak var deleteProfileButton: UIButton!
    
    var userPhone = ""
    
    var profile: Profile?
    
    var datePicker = UIDatePicker()
    var genderPicker = UIPickerView()
    var categoryPicker = UIPickerView()
    
    var categories: [Category?] = []
    var categoryId: Int?
    var gender = 0
    
    // for location
    var latitude = 0.0
    var longitude = 0.0
    var addressText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        birthtimeTF.inputView = datePicker
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderTF.inputView = genderPicker
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        serviceCategoryTF.inputView = categoryPicker
        
        experienceTV.delegate = self
        aboutCompanyTV.delegate = self
        
        
        
        // set picker style
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        // set min & max date
        datePicker.minimumDate = .some(Date(timeIntervalSince1970: -2208988800))
        datePicker.maximumDate = .some(Date())
        
        //set default date
        datePicker.date = Date()
        
        let loc = Locale(identifier: "ru_RU")
        self.datePicker.locale = loc
        
        //set
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let _ = dateFormatter.string(from: datePicker.date)
        
        birthtimeTF.addTarget(self, action: #selector(editingEnded), for: .editingDidEnd)
        
        serviceSwitch.addTarget(self, action: #selector(changeSwitch), for: .allEvents)
        
        locationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openMap)))
        avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editAvatar)))
        photoImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editAvatar)))
        
        profile = getProfile()
        locationTF.text = profile?.location ?? ""
        latitude = profile?.lat ?? 0.0
        longitude = profile?.lon ?? 0.0
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
        serviceCategoryView.alpha = 0
        serviceCategoryView.isHidden = true
        
        firstNameView.addSmallRadius()
        lastNameView.addSmallRadius()
        patronymicView.addSmallRadius()
        aboutCompanyView.addSmallRadius()
        genderView.addSmallRadius()
        birthtimeView.addSmallRadius()
        locationView.addSmallRadius()
        businessSiteView.addSmallRadius()
        emailView.addSmallRadius()
        tgView.addSmallRadius()
        phoneView.addSmallRadius()
        serviceCategoryView.addSmallRadius()
        userSiteView.addSmallRadius()
        experienceView.addSmallRadius()
        

        
        exitProfileButton.addSmallRadius()
        deleteProfileButton.addSmallRadius()
        
        nextButton.addSmallRadius()
        
        avatar.sd_imageIndicator = SDWebImageActivityIndicator.gray
        avatar.sd_setImage(with: URL(string: getProfile()?.avatar ?? ""), placeholderImage: UIImage(named: "Avatar"), options: [], context: [:])
        
        firstNameTF.text = profile?.firstName ?? ""
        lastNameTF.text = profile?.lastName ?? ""
        patronymicTF.text = profile?.patronymic ?? ""
        
        birthtimeTF.text = profile?.birthtime?.toDay
        gender = profile?.gender ?? 0
        genderTF.text = Constants.gender[gender + 1]

        emailTF.text = profile?.email ?? ""
        tgTF.text = profile?.tg ?? ""
        businessSiteTF.text = profile?.site ?? ""
        userSiteTF.text = profile?.site ?? ""
        
        if profile?.companyInfo == nil || profile?.companyInfo == "" {
            aboutCompanyTV.text = "Информация о компании"
            aboutCompanyTV.textColor = UIColor.lightGray
        } else {
            aboutCompanyTV.text = profile?.companyInfo
        }
        
        if profile?.experience == nil || profile?.experience == "" {
            experienceTV.text = "Опыт работы"
            experienceTV.textColor = UIColor.lightGray
        } else {
            experienceTV.text = profile?.experience
        }
        
        phoneTF.text = JMStringMask.initWithMask("+000 000 000 000")?.maskString(getProfile().tel)
        
        showTelSwitch.isOn = profile?.showTel ?? true
        
        if profile?.isServicer == true {
            serviceSwitch.isOn = true
            serviceCategoryTF.text = profile?.category?.name ?? ""
            categoryId = profile?.category?.id ?? 0
            serviceCategoryView.alpha = 1
            serviceCategoryView.isHidden = false
        } else {
            serviceSwitch.isOn = false
        }
        
        
        
        
        if getProfile().isBusiness == true {
            firstNameTF.placeholder = "Название компании"
            locationTF.placeholder = "Адрес"
            lastNameView.isHidden = true
            patronymicView.isHidden = true
            genderView.isHidden = true
            birthtimeView.isHidden = true
            userSiteView.isHidden = true
            experienceView.isHidden = true
        } else {
            businessSiteView.isHidden = true
            aboutCompanyView.isHidden = true
        }
    }
    
    
    @IBAction func close(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func exitApp(_ sender: UIButton){
        exitAppClearKeychain()
    }
    
    
    //MARK: TEXT VIEW
    func textViewDidBeginEditing(_ textView: UITextView) {

        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        

    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = UIColor.lightGray
            if textView == aboutCompanyTV {
                textView.text = "Информация о компании"
            } else {
                textView.text = "Опыт работы"
            }
        }
    }
    //max length
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 180    // 10 Limit Value
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
    
    
    //MARK: CATEGORY SWITCH
    @objc func changeSwitch(_ sender: UISwitch){
        if serviceSwitch.isOn {
            UIView.animate(withDuration: 1, delay: 0) { [weak self] in
                self?.serviceCategoryView.alpha = 1
                self?.serviceCategoryView.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 1, delay: 0) { [weak self] in
                self?.serviceCategoryView.alpha = 0
                self?.serviceCategoryView.isHidden = true
            }
        }
    }
    
    

    // MARK: GET CATEGORIES
    func getCategories(){
        spinner.startAnimating()
        makeRequest(with: RSignUpModel.fetchCategories()) { [weak self] data in
            if let categories = data?.data {
                self?.categories = categories
                self?.serviceCategoryTF.text = self?.profile?.category?.name ?? ""
                self?.categoryId = self?.profile?.category?.id ?? 0
            }
            self?.spinner.stopAnimating()
        }
    }
    
    //MARK: SIGN IN | UPDATE USER
    @IBAction func updateUser(_ sender: UIButton) {
        
        if getProfile().isBusiness == true {
            if locationTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                view.makeToast("Необходимо указать название")
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
            
//            if birthtimeTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
//                view.makeToast("Необходимо указать дату рождения")
//                return
//            }
        }
        if locationTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            view.makeToast("Необходимо указать адрес")
            return
        }
        if serviceSwitch.isOn{
            if serviceCategoryTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                view.makeToast("Необходимо указать категорию услуг")
                return
            }
        }
        
        var site  = ""
        if profile?.isBusiness == true {
            site = businessSiteTF.text!
        } else  {
            site = userSiteTF.text!
        }
        
        var experience = ""
        if experienceTV.text != "Опыт работы" {
            experience = experienceTV.text!
        }
        
        
        var companyInfo = ""
        if aboutCompanyTV.text != "Информация о компании" {
            companyInfo = aboutCompanyTV.text!
        }
        
        
        spinner.startAnimating()
        firstly{
            ProfileModel.editProfile(firstName: firstNameTF.text!, lastName: lastNameTF.text!, patronymic: patronymicTF.text!, email: emailTF.text ?? nil, tg: tgTF.text ?? nil, isServicer: serviceSwitch.isOn, gender: gender - 1, birthtime: Int(datePicker.date.timeIntervalSince1970), location: locationTF.text!, serviceCategory: categoryId, showTel: showTelSwitch.isOn, isBusiness: getProfile().isBusiness!, companyInfo: companyInfo, site: site, experience: experience, lat: latitude, lon: longitude)
        }.done { [weak self] data in
            
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.view.makeToast("Данные успешно сохранены", point: .init(x: (self?.view.bounds.width)! / 2, y: (self?.view.bounds.height ?? 0)! - 120), title: .none, image: .none) { _ in
                    self?.updateProfileData(profile: (data.data)!)
                    self?.navigationController?.popViewController(animated: true)
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
    
    //MARK: DELETE ACCOUNT
    @IBAction func deleteProfile(_ sender: UIButton){
        let alert = UIAlertController(title: "Внимание", message: "Вы действительно хотите удалить данные профиля. Вся информация будет удалена без возможности восстановления", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            self?.deleteAccount()
        }
        let cancel = UIAlertAction(title: "Нет", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    
    func deleteAccount(){
        firstly{
            ProfileModel.deleteProfile()
        }.done { [weak self] data in
            self?.spinner.stopAnimating()
            if data.message!.lowercased() == "ok"{
                UserDefaults.standard.set(0, forKey: "id")
                UserDefaults.standard.set(false, forKey: "isRegistered")
                UserDefaults.standard.set("", forKey: "email")
                UserDefaults.standard.set("", forKey: "tel")
                UserDefaults.standard.set("", forKey: "firstName")
                UserDefaults.standard.set("", forKey: "lastName")
                UserDefaults.standard.set("", forKey: "patronymic")
                UserDefaults.standard.set(0, forKey: "birthtime")
                UserDefaults.standard.set(nil, forKey: "gender")
                UserDefaults.standard.set("", forKey: "avatar")
                UserDefaults.standard.set(nil, forKey: "location")
                UserDefaults.standard.set(0.0, forKey: "rating")
                UserDefaults.standard.set(nil, forKey: "categoryId")
                UserDefaults.standard.set(Data(), forKey: "category")
                UserDefaults.standard.set(nil, forKey: "lastVisited")
                UserDefaults.standard.set("", forKey: "lastVisitedHuman")
                UserDefaults.standard.set(true, forKey: "isActive")
                UserDefaults.standard.set(false, forKey: "isSuperuser")

                UserDefaults.standard.set(0, forKey: "storiesCount")
                UserDefaults.standard.set(0, forKey: "hugsCount")
                UserDefaults.standard.set(true, forKey: "isOnline")
                UserDefaults.standard.set(false, forKey: "iBlock")
                UserDefaults.standard.set(false, forKey: "blockMe")
                
                UserDefaults.standard.set(0, forKey: "createdAdsCount")
                UserDefaults.standard.set(0, forKey: "completedAdsCount")
                UserDefaults.standard.set(0, forKey: "myOffersCount")
                
                UserDefaults.standard.set(0, forKey: "tg")
                
                UserDefaults.standard.set(false, forKey: "isServicer")
                UserDefaults.standard.set(false, forKey: "showTel")
                
                UserDefaults.standard.set("", forKey: "firebaseToken")
                
                self?.clearKeychain()
                
                let sBoard = UIStoryboard(name: "Initial", bundle: .main)
                let vc = sBoard.instantiateInitialViewController()
                
                vc?.modalPresentationStyle = .fullScreen
                self?.present(vc!, animated: true)
            } else {
                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            print(error.localizedDescription)
            self?.spinner.stopAnimating()
        }
    }
    //MARK: UNWIND
    @IBAction func unwindEditProfile(_ sender: UIStoryboardSegue){
        locationTF.text = addressText
    }
    
    //OPEN MAP
    @objc func openMap(_ sender: Any){
        let sBoard = UIStoryboard(name: "Map", bundle: .main)
        guard let controller = sBoard.instantiateViewController(withIdentifier: "selectCoordinateVC") as? SelectCoordinateController else { return }
        controller.modalPresentationStyle = .fullScreen
        controller.coordinateType = .editProfile
        self.presentPanModal(controller)
    }
}


//MARK: PICKERS
extension EditProfileController: UIPickerViewDelegate, UIPickerViewDataSource {
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
extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
