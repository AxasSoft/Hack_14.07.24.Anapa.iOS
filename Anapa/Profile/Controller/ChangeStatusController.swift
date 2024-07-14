//
//  ChangeStatusController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 12.10.2023.
//

import UIKit
import PromiseKit
import Toast_Swift
import PanModal

class ChangeStatusController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var statusTV: UITextView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        statusTV.delegate = self
        if getProfile().status != nil && getProfile().status != "" {
            statusTV.text = getProfile().status
        } else {
            statusTV.text = "Введите текст"
            statusTV.textColor = UIColor.lightGray
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        spinner.stopAnimating()
        confirmButton.addRadius()
    }
    
    
    //MARK: TEXT VIEW
    func textViewDidEndEditing(_ textView: UITextView) {
        if statusTV.text.isEmpty {
            statusTV.text = "Введите текст"
            statusTV.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if statusTV.text == "Введите текст" {
            statusTV.text = ""
            statusTV.textColor = UIColor.black
    }
    }

    @IBAction func close(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: ADD OFFER
    @IBAction func changeStatus(_ sender: UIButton){
        if statusTV.text == "" || statusTV.text == "Введите текст" {
            view.makeToast("Укажите статус. Он будет отображён в шапке профиля")
            return
        }
        spinner.startAnimating()
        firstly{
            ProfileModel.changeStatus(status: statusTV.text!)
        }.done { [weak self] data in
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.view.makeToast("Статус успешно изменён", point: .init(x: (self?.view.bounds.width)! / 2, y: (self?.view.bounds.height ?? 0)! - 120), title: .none, image: .none) { _ in
                    self?.dismiss(animated: true)
                }
            } else {
                self?.spinner.stopAnimating()
                
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
}

//MARK: - PanModalPresentable
extension ChangeStatusController: PanModalPresentable {
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(420)
    }
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var showDragIndicator: Bool {
        true
    }
}

