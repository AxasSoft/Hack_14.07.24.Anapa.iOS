//
//  SubscribeController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 20.06.2023.
//

import UIKit
import PromiseKit
import Toast_Swift
import SDWebImage

class SubscribeController: UIViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var subscribeTable: UITableView!
    
    @IBOutlet weak var subscribersButton: UIButton!
    @IBOutlet weak var subscriptionsButton: UIButton!
    @IBOutlet weak var storyButton: UIButton!
    
    var users: [Profile?] = []
    
    var selectUser: Profile?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribersButton.addRadius()
        subscriptionsButton.addRadius()
        storyButton.addRadius()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getSubscribers()
        
        subscribersButton.setTitleColor(UIColor.white, for: .normal)
        subscribersButton.backgroundColor = UIColor(named: "AccentColor")
    }
    
    @IBAction func close(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: CHANGE SUBSCRIBE | SUBSCRIPTIONS CATEGORY
    @IBAction func changeSubscribe(_ sender: UIButton){
        subscribersButton.setTitleColor(UIColor.black, for: .normal)
        subscribersButton.backgroundColor = UIColor.white
        subscriptionsButton.setTitleColor(UIColor.black, for: .normal)
        subscriptionsButton.backgroundColor = UIColor.white
        users = []
        if sender == subscribersButton {
            subscribersButton.setTitleColor(UIColor.white, for: .normal)
            subscribersButton.backgroundColor = UIColor(named: "AccentColor")
            getSubscribers()
        } else {
            subscriptionsButton.setTitleColor(UIColor.white, for: .normal)
            subscriptionsButton.backgroundColor = UIColor(named: "AccentColor")
            getSubscriptions()
        }
        
    }
    
    
    //MARK: GET SUBSCRIBE
    func getSubscribers(){
        spinner.startAnimating()
        firstly{
            MainModel.fetchSubscriptions()
        }.done { [weak self] data in
            // if ok
            self?.spinner.stopAnimating()
            if (data.message!.lowercased() == "ok") {
                self?.users = data.data
                self?.subscribeTable.reloadData()
            }
        }.catch{  [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    
    
    //MARK: GET SUBSCRIBE
    func getSubscriptions(){
        spinner.startAnimating()
        firstly{
            MainModel.fetchSubscribers()
        }.done { [weak self] data in
            // if ok
            self?.spinner.stopAnimating()
            if (data.message!.lowercased() == "ok") {
                self?.users = data.data
                self?.subscribeTable.reloadData()
            }
        }.catch{  [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUser"{
            let destinationVC = segue.destination as! UserController
            destinationVC.user = selectUser
            destinationVC.userId = selectUser?.id
        }
    }
}

//MARK: TABLE
extension SubscribeController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserInfoTableViewCell
        
        userCell.avatar.sd_imageIndicator = SDWebImageActivityIndicator.gray
        userCell.avatar.sd_setImage(with: URL(string: users[indexPath.row]?.avatar ?? ""), placeholderImage: UIImage(named: "Avatar"))
        
        userCell.name.text = (users[indexPath.row]?.firstName ?? "") + " " + (users[indexPath.row]?.lastName ?? "")
        userCell.lastVisit.text = users[indexPath.row]?.lastVisitedHuman
        
        return userCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < users.count {
            selectUser = users[indexPath.row]
            performSegue(withIdentifier: "showUser", sender: nil)
        }
    }
    
}
