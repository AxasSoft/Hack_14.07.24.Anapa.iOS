//
//  ComplaintController.swift
//  NotAlone
//
//  Created by Сергей Майбродский on 03.08.2022.
//

import UIKit
import Toast_Swift
import PromiseKit

class ComplaintController: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var complaiintTF: UITextField!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var complaintButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var spinner :UIActivityIndicatorView!

    
    var complaintPicker = UIPickerView()
    var complaintsID: Int?
    var complaintType: Int? // story = 0, profile = 1
    var culpritID: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        complaintPicker.delegate = self
        complaintPicker.dataSource = self
        
        complaiintTF.inputView = complaintPicker
        
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    
    func setupUI(){
        backView.addRadius()
        complaintButton.addSmallRadius()
        cancelButton.addSmallRadius()
        complaiintTF.addSmallRadius()
        comment.addSmallRadius()
        spinner.stopAnimating()
    }
    
    
    @IBAction func close(_ sender: UIButton){
        dismiss(animated: true)
    }
    
    
    @IBAction func sendComplaint(_ sender: UIButton){
        if complaintType == 0 {
            complaintStory()
        } else {
            complaintUser()
        }
    }
    
    
    
    
    //MARK: COMPLAINT STORY
    func complaintStory(){
        if comment.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            view.makeToast("Необходимо указать комментарий")
            return
        }
        spinner.startAnimating()
        firstly{
            StoriesModel.complaintStory(storyId: culpritID ?? 0, complaint: complaintsID ?? 0, comment: comment.text)
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.view.makeToast("Жалоба направлена и будет рассмотрена администрацией в ближайшее время", point: .init(x: (self?.view.bounds.width)! / 2, y: (self?.view.bounds.height)! - 120), title: .none, image: .none) { _ in
                    self?.dismiss(animated: true)
                }
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    
    
    //MARK: COMPLAINT USER
    func complaintUser(){
        if comment.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            view.makeToast("Необходимо указать комментарий")
            return
        }
        spinner.startAnimating()
        firstly{
            ProfileModel.complaintUser(userId: culpritID ?? 0, complaint: complaintsID ?? 0, comment: comment.text)
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.view.makeToast("Жалоба направлена и будет рассмотрена администрацией в ближайшее время", point: .init(x: (self?.view.bounds.width)! / 2, y: (self?.view.bounds.height)! - 120), title: .none, image: .none) { _ in
                    self?.dismiss(animated: true)
                }
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    
}
    
    //MARK: PICKERS
    extension ComplaintController: UIPickerViewDelegate, UIPickerViewDataSource {
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
                return Constants.complaints.count
        }
        
        internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return "\(Constants.complaints[row] ?? "")"
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            complaiintTF.text = "\(Constants.complaints[row] ?? "")"
                complaintsID = row
        }
    }
    

