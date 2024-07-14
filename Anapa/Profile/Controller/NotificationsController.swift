//
//  NotificationsController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 22.01.2023.
//

import UIKit
import PromiseKit
import Toast_Swift
import LoadingShimmer
import SDWebImage

class NotificationsController: UIViewController {
    
    @IBOutlet weak var notificationHint: UIStackView!
    @IBOutlet weak var notificationTable: UITableView!
    
    var refreshControl = UIRefreshControl()
    
    var notifications: [NotificationInfo?] = []
    
    var selectNotification: NotificationInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationTable.delegate = self
        notificationTable.dataSource = self

        refreshControl.attributedTitle = NSAttributedString(string: "Потяните вниз чтобы обновить")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        notificationTable.addSubview(refreshControl)
    }
    

    @IBAction func close(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        notificationHint.isHidden = true
        notifications = []
        getNotification()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    //MARK: REFERSH TABLE
    @objc func refreshData(){
        notifications = []
        getNotification()
        viewWillAppear(true)
        notificationTable.reloadData()
        refreshControl.endRefreshing()
    }
    
    //MARK: GET NOTIFICATION
    func getNotification(){
        LoadingShimmer.startCovering(notificationTable, with: [])
        firstly{
            ProfileModel.fetchNotification()
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                LoadingShimmer.stopCovering(self?.notificationTable)
                self?.notifications = data.data
                self?.notificationTable.reloadData()
                if self?.notifications.count == 0 {
                    self?.notificationHint.isHidden = false
                    self?.notificationTable.isHidden = true
                } else {
                    self?.notificationHint.isHidden = true
                    self?.notificationTable.isHidden = false
                }
            } else {
                LoadingShimmer.stopCovering(self?.notificationTable)
                self?.view.makeToast(data.description)
                self?.notificationTable.reloadData()
            }
        }.catch{ [weak self] error in
            LoadingShimmer.stopCovering(self?.notificationTable)
            print(error.localizedDescription)
            self?.notificationTable.reloadData()
        }
    }

    
    //MARK: READ NOTIFICATION
    func readNotification(notificationId: Int){
        firstly{
            ProfileModel.readNotification(notificationId: notificationId)
        }.done { [weak self] data in
            // if ok
            print("ok")
        }.catch{ [weak self] error in
            print(error.localizedDescription)
        }
    }

    @IBAction func goFeedback(_ sender: UIButton){
        selectNotification = notifications[sender.tag]
        performSegue(withIdentifier: "addFeedback", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addFeedback" {
            let destinationVC = segue.destination as! FeedbackController
//            destinationVC.notification = selectNotification
        }
    }
}




extension NotificationsController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notifCell = tableView.dequeueReusableCell(withIdentifier: "notifCell", for: indexPath) as! NotificationTableViewCell
        notifCell.created.text = notifications[indexPath.row]?.created?.toDay
        notifCell.cover.sd_setImage(with: URL(string: notifications[indexPath.row]?.secondUser?.avatar ?? ""), placeholderImage: UIImage(named: "AppIcon"))
        notifCell.title.text =  notifications[indexPath.row]?.title ?? ""
        notifCell.notifText.text =  notifications[indexPath.row]?.body ?? ""
        if  notifications[indexPath.row]?.hasFeedbackAboutMe == false && (notifications[indexPath.row]?.stage == 3 || notifications[indexPath.row]?.stage == 2) {
            notifCell.reviewButton.isHidden = true
        } else {
            notifCell.reviewButton.isHidden = true
        }
        
        readNotification(notificationId: notifications[indexPath.row]?.id ?? 0)
        
        notifCell.reviewButton.tag = indexPath.row
        return notifCell
    }
    
    
}
