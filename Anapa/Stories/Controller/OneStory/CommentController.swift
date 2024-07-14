//
//  OneStooryController.swift
//  NotAlone
//
//  Created by Сергей Майбродский on 01.07.2022.
//

import UIKit
import PromiseKit
import Toast_Swift
import SDWebImage
import IQKeyboardManagerSwift

class CommentController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var commentTF: UITextView!
    @IBOutlet weak var commentTable: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var comments: [Comment?] = []
    
    var profile: Profile?
    var story: Story?
    var viewProfileId = 0
    var page = 1
    
    var activeField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToHideKeyboard()
        commentTF.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        getComments(page: page)
        setLooked()
        profile = getProfile()
        setupUI()
        
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        
        
        
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
    }
    
    func setupUI() {
        avatar.setOval()
        spinner.stopAnimating()
        avatar.sd_setImage(with: URL(string: profile?.avatar ?? ""), placeholderImage: UIImage(named: "Avatar"), options: [], context: [:])
        commentTF.addSmallRadius()
        commentTF.layer.borderWidth = 1
        commentTF.layer.borderColor = UIColor(named: "BarBackground")?.cgColor
    }
    
    @IBAction func close(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
//        navigationController?.popViewController(animated: true)
    }
    
    
    @IBOutlet weak var viewConstraint: NSLayoutConstraint!
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        var height = (keyboardSize?.height ?? 0)
        if height < 200 {
            height = 320
        } else if height < 300 {
            height += 100
        }
//        self.scrollView.contentInset = contentInsets
        viewConstraint.constant = height
        

        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
//                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }

    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        viewConstraint.constant = 0
        self.view.endEditing(true)
    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeField = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeField = nil
    }
//    func textFieldDidBeginEditing(_ textField: UITextField){
//
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField){
//
//    }
    
    //MARK: SHOW PROFILE
    @IBAction func showUserProfile(_ sender: UIButton){
        if sender.tag == 0{
            view.makeToast("Ошибка получения профиля")
            return
        }
        if sender.tag != profile?.id {
            viewProfileId = sender.tag
            self.performSegue(withIdentifier: "showUserProfile", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserProfile" {
            let destinationVC = segue.destination as! UserController
//            destinationVC.userId = viewProfileId
        }
    }
    
    
    //MARK: GET COMMENTS
    func getComments(page: Int){
        spinner.startAnimating()
        firstly{
            StoriesModel.fetchStoryComments(storyId: story?.id ?? 0, page: page)
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.comments = data.data
                self?.commentTable.reloadData()
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
            //            self?.view.makeToast("Не удалось связаться с сервером. Проверьте подключение к сети интернет")
        }
    }
    
    //MARK: ADD COMMENT
    @IBAction func addComment(_ sender: UIButton){
        if commentTF.text?.trimmingCharacters(in: .whitespaces) == "" {
            view.makeToast("Введите текст комментария")
            return
        }
        spinner.startAnimating()
        firstly{
            StoriesModel.addComment(storyId: story?.id ?? 0, text: commentTF.text!)
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.getComments(page: self?.page ?? 1)
                self?.commentTF.text = ""
                self?.commentTable.reloadData()
                self?.view.endEditing(true)
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
            //            self?.view.makeToast("Не удалось связаться с сервером. Проверьте подключение к сети интернет")
        }
    }
    
    //MARK: DELETE COMMENT
    func deleteComment(index: Int){
        spinner.startAnimating()
        firstly{
            StoriesModel.deleteComment(commentId: comments[index]?.id ?? 0)
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.comments.remove(at: index)
                self?.commentTable.reloadData()
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
            //            self?.view.makeToast("Не удалось связаться с сервером. Проверьте подключение к сети интернет")
        }
    }
    
    
    //MARK: SET LOOKED
    func setLooked(){
        spinner.startAnimating()
        firstly{
            StoriesModel.viewStory(storyId: self.story?.id ?? 0)
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                self?.spinner.stopAnimating()
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
            //            self?.view.makeToast("Не удалось связаться с сервером. Проверьте подключение к сети интернет")
        }
    }

}



//MARK: TABLE VIEW
extension CommentController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let commentCell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
        let transformer = SDImageResizingTransformer(size: CGSize(width: 500, height: 500), scaleMode: .aspectFill)
        commentCell.avatar.sd_setBackgroundImage(with: URL(string: comments[indexPath.row]?.user?.avatar ?? ""), for: .normal, placeholderImage: UIImage(named: "Avatar"), options: [], context: [.imageTransformer: transformer])
        commentCell.avatar.tag = comments[indexPath.row]?.user?.id ?? 0
        commentCell.name.setTitle((comments[indexPath.row]?.user?.firstName ?? "") + " " + (comments[indexPath.row]?.user?.lastName ?? ""), for: .normal)
        commentCell.name.tag = story?.user?.id ?? 0
        commentCell.avatar.setOval()
        commentCell.textComment.text = comments[indexPath.row]?.text
        commentCell.date.text = comments[indexPath.row]?.created?.toDay
        
        return commentCell
    }
    
    //MARK: DELETE
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row < comments.count && comments[indexPath.row]?.user?.id == getProfile().id{
            return true
        } else {
            return false
        }
        
    }
    
        
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal,
                                              title: "Удалить") { [weak self] (action, view, completionHandler) in
            self?.deleteComment(index: indexPath.row)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

