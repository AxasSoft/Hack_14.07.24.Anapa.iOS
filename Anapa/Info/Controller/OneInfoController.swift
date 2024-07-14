//
//  OneNewsController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 23.01.2023.
//

import UIKit
import SDWebImage
import SwiftyMarkdown
import PromiseKit
import YandexMobileMetrica

class OneInfoController: UIViewController {

    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var body: UITextView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var autorView: UIView!
    @IBOutlet weak var autorName: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var lastActive: UILabel!
    
    var info: Info?
    var infoId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        autorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openUser)))
    }
    
    
    @IBAction func close(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func openUser(_ sender: UIButton){
        if !UserDefaults.standard.bool(forKey: "isRegistered") {
            view.makeToast("Для просмотра профиля необходимо зарегистрироваться")
            return
        }
        
        if info?.user?.id == nil{
//            view.makeToast("Ошибка получения профиля")
            return
        }
        if info?.user?.id == getProfile()?.id {
            tabBarController?.selectedIndex = 4
            return
        }
        
        let storyboard = UIStoryboard(name: "Profile", bundle: .main)
        let userVC = storyboard.instantiateViewController(withIdentifier: "UserVC") as? UserController
        show(userVC!, sender: nil)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spinner.stopAnimating()
        
        autorView.addRadius()
        
        if infoId != nil {
                fetchInfoBlocks(category: nil, search: nil)
        } else {
            avatar.setOval()
            if info?.user == nil || info?.user?.id == 1{
                autorView.isHidden = true
                avatar.image = UIImage(named: "Logo")
                autorName.text = "Anapa"
                lastActive.text = "В сети"
                info?.user?.id = 1
            } else {
                UserDefaults.standard.set(nil, forKey: "deepLink")
                avatar.sd_setImage(with: URL(string: info?.user?.avatar ?? ""), placeholderImage: UIImage(named: "Avatar"))
                autorName.text = (info?.user?.firstName ?? "") + " " +  (info?.user?.lastName ?? "")
                lastActive.text = info?.user?.lastVisitedHuman
            }
            
            
            if info?.image == nil {
                cover.isHidden = true
            } else {
                cover.isHidden = false
                cover.sd_setImage(with: URL(string: info?.image ?? ""), placeholderImage: UIImage(named: "Cover"))
            }
            
            YMMYandexMetrica.reportEvent("OPEN INFO", parameters: ["Title": info?.title ?? ""], onFailure: { (error) in
                print("REPORT ERROR: %@", error.localizedDescription)
            })
            
            titleLabel.text = info?.title ?? ""
            body.attributedText = SwiftyMarkdown(string: info?.body ?? "").attributedString()

        }
    }
    
    
    
    //MARK: GET INFOS
    func fetchInfoBlocks(category: Int?, search: String?){
        spinner.startAnimating()
        firstly{
            InfoModel.fetchInfoBlocks(category: category, search: search?.trimmingCharacters(in: .whitespacesAndNewlines), page: nil)
        }.done { [weak self] data in
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                for info in data.data {
                    if info?.id == self?.infoId {
                        self?.info = info
                        self?.infoId = nil
                        self?.viewWillAppear(true)
                    }
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


extension String {

    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
