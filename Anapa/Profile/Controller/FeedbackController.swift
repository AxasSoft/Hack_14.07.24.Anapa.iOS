//
//  FeedbackController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 02.04.2023.
//

import UIKit
import PromiseKit
import Toast_Swift
import Cosmos
import SDWebImage

class FeedbackController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var commentTV: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var order: Order?
    var user: Profile?
    
//    var notification: NotificationInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        userInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showUserInfo)))
        rating.rating = 0
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spinner.stopAnimating()
        topView.bottomRadius()
        commentView.topRadius()
        avatar.setOval()
        sendButton.addRadius()
        
        projectName.text = order?.title ?? ""
        avatar.sd_imageIndicator = SDWebImageActivityIndicator.gray
        avatar.sd_setImage(with: URL(string: user?.avatar ?? ""), placeholderImage: UIImage(named: "Avatar"), options: [], context: [:])
        name.text = (user?.firstName ?? "") + " " + (user?.lastName ?? "")
        date.text = order?.created?.toDay ?? ""
        
    }
    
    @IBAction func close(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: SHOW USER
    @objc func showUserInfo(_ sender: Any){
        performSegue(withIdentifier: "showUser", sender: nil)
    }
    
    //MARK: ADD FEEDBACK
    @IBAction func addFeedback(_ sender: UIButton){
        
        if Int(rating.rating) == 0{
            view.makeToast("Необходимо поставить оценку")
            return
        }
        
        if commentTV.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            view.makeToast("Необходимо добавить текст отзыва")
            return
        }
        
        spinner.startAnimating()
        firstly{
            ProfileModel.addFeedback(offerId: order?.winOffer?.id ?? 0, rating: Int(rating.rating), text: commentTV.text.trimmingCharacters(in: .whitespacesAndNewlines))
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.view.makeToast("Отзыв успешно добавлен", point: .init(x: (self?.view.bounds.width)! / 2, y: (self?.view.bounds.height ?? 0)! - 120), title: .none, image: .none) { _ in
//                    self?.dismiss(animated: true)
                    if (self?.order?.winOffer?.user?.id ?? 0) == self?.getProfile().id {
                        self?.performSegue(withIdentifier: "unwindMyOffers", sender: nil)
                    } else {
                        self?.performSegue(withIdentifier: "unwindMyOrder", sender: nil)
                    }
                }
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.description)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    
    //MARK: SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUser"{
            let destinationVC = segue.destination as! UserController
            destinationVC.userId = user?.id
        }
    }
}
