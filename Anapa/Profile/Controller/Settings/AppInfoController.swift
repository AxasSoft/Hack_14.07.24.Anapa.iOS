//
//  AboutAutorController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 03.02.2023.
//

import UIKit
import PromiseKit
import Toast_Swift
import SDWebImage
import SwiftyMarkdown

class AppInfoController: UIViewController{

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var infoBlock = ""
    var link = ""

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        getInfo()
        
        
        
        switch infoBlock {
        case "about":
            actionButton.isHidden = true
            backButton.setTitle("О авторе проекта", for: .normal)
        case "app":
            actionButton.isHidden = true
            backButton.setTitle("О приложении", for: .normal)
        case "donations":
            cover.isHidden = true
            backButton.setTitle("Поддержать проект", for: .normal)
        default:
            actionButton.isHidden = true
            backButton.setTitle("О авторе проекта", for: .normal)
        }
        
        actionButton.addSmallRadius()
    }
    
    @IBAction func close(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func tapActionButton(_ sender: UIButton){
        UIApplication.shared.open(URL(string: link)!)
    }
    
    //MARK: GET INFO
    func getInfo(){
        spinner.startAnimating()
        
        
        firstly{
            ProfileModel.fetchServiceInfo(slug: infoBlock)
        }.done { [weak self] data in
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.cover.sd_setImage(with: URL(string: data.data?.image ?? ""), placeholderImage: UIImage(named: ""))
                self?.text.attributedText = SwiftyMarkdown(string: data.data?.body ?? "").attributedString()
                self?.link = data.data?.link ?? ""
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.description)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
}
