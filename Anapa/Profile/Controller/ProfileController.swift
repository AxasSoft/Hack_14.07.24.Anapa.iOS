//
//  ProfileController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 20.01.2023.
//

import UIKit
import PromiseKit
import Toast_Swift
import SDWebImage
import SwiftyMarkdown

class ProfileController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var secondAvatarView: UIView!
    @IBOutlet weak var secondAvatarImage: UIImageView!
    @IBOutlet weak var secondAvatarName: UILabel!
    
    @IBOutlet weak var profileCoverHeight: NSLayoutConstraint!
    @IBOutlet weak var profileCover: UIImageView!
    @IBOutlet weak var profileTable: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var hintProfile: UIStackView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    var refreshControl = UIRefreshControl()
    
    
    var profile: Profile?
    var stories: [Story?] = []
    
    let collectionMargin = CGFloat(16)
    let itemSpacing = CGFloat(10)
    let itemHeight = CGFloat(322)
    var itemWidth = CGFloat(0)
    var storedOffsets = [Int: CGFloat]()
    var hashtagId: Int?
    var page = 1
    var userId: Int?
    var viewProfileId: Int?
    var viewStory: Story?
    var complaintId: Int?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileTable.delegate = self
        profileTable.dataSource = self
        
        profile = getProfile()
        setupUI()
        
        tabBarController?.tabBar.isHidden = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerButton.addRadius()
        if UserDefaults.standard.bool(forKey: "isRegistered") == false {
            profileTable.isHidden = true
            hintProfile.isHidden = false
            settingsButton.isHidden = true
        } else {
            profileTable.isHidden = false
            hintProfile.isHidden = true
            settingsButton.isHidden = false
        }
        setupUI()
        getStories(search: nil)
        updateProfile()

        
        settingsButton.menu = UIMenu(children : [
            UIAction(title : "Уведомления", image: UIImage(systemName: "bell"), handler: {_ in self.showNotification()}),
            UIAction(title : "Редактировать статус", image: UIImage(systemName: "pencil.line"), handler: {_ in self.changeStatus()}),
            UIAction(title : "Поиск", image: UIImage(systemName: "magnifyingglass"), handler: {_ in self.showSearch()}),
//            UIAction(title : "Сохраненное", image: UIImage(systemName: "bookmark"), handler: {_ in self.showSaved()}),
            UIAction(title : "Настройки", image: UIImage(named: "SettingsBlack"), handler: {_ in self.showSettings()}),
            UIAction(title : "Редактировать обложку", image: UIImage(systemName: "photo.fill"), handler: {_ in self.editProfileCover()})])

        settingsButton.showsMenuAsPrimaryAction = true
        
    }
    
    
    //MARK: MAIN BUTTON
    func showSettings(){
        let vsSboard = UIStoryboard(name: "Profile", bundle: .main)
        let vc = (vsSboard.instantiateViewController(identifier: "SettingsVC") as! SettingsController?)!
        self.show(vc, sender: nil)
    }
    
    func showNotification(){
        let vsSboard = UIStoryboard(name: "Profile", bundle: .main)
        let vc = (vsSboard.instantiateViewController(identifier: "NotificationsVC") as! NotificationsController?)!
        self.show(vc, sender: nil)
    }
    
    func showSearch(){
        let vsSboard = UIStoryboard(name: "Profile", bundle: .main)
        let vc = (vsSboard.instantiateViewController(identifier: "SearchVC") as! SearchController?)!
        self.show(vc, sender: nil)
    }
    func showSaved() {
        let vcSboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = vcSboard.instantiateViewController(withIdentifier: "SubscribeVC") as! SubscribeController
        self.show(vc, sender: nil)
    }
    
    func openSupport(){
        UIApplication.shared.open(URL(string: "https://t.me/iAXAS")!)
    }
    
    func changeStatus() {
        let sBoard = UIStoryboard(name: "Profile", bundle: .main)
        guard let controller = sBoard.instantiateViewController(withIdentifier: "ChangeStatusVC") as? ChangeStatusController  else { return }
        controller.modalPresentationStyle = .fullScreen
        self.presentPanModal(controller)
    }
    
    func setupUI(){

        backButton.setOval()
        settingsButton.setOval()
//        if getProfile().isBusiness == true || getProfile().id == 3 {
            profileCover.sd_setImage(with: URL(string: getProfile().profileCover ?? ""), placeholderImage: UIImage(named: ""))
//        }

        secondAvatarImage.alpha = 0
        secondAvatarImage.setOval()
        secondAvatarImage.sd_setImage(with: URL(string: getProfile().avatar ?? "" ), placeholderImage: UIImage(named: "Avatar"))
        secondAvatarView.alpha = 0
        secondAvatarView.addRadius()
        secondAvatarName.text = (getProfile().firstName ?? "") + " " + (getProfile().lastName ?? "")
        spinner.stopAnimating()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Потяните вниз чтобы обновить")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        profileTable.addSubview(refreshControl)
    }
    
    @IBAction func close(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: GO REGISTER
    @IBAction func goRegister(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: GET PROFILE
    func updateProfile(){
        spinner.startAnimating()
        firstly{
            ProfileModel.fetchProfile()
        }.done { [weak self] data in
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.updateProfileData(profile: data.data!)
                self?.profile = self?.getProfile()
                self?.profileTable.reloadData()
                self?.setupUI()
            } else {
                self?.spinner.stopAnimating()
                self?.profileTable.reloadData()
                //                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            self?.profileTable.reloadData()
            print(error.localizedDescription)
            //            self?.view.makeToast("Не удалось связаться с сервером. Проверьте подключение к сети интернет")
        }
    }
    
    //MARK: EDIT PROFILE COVER
    func editProfileCover(){
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
    
    //MARK: UPLOAD PROFILE COVER
    func changeProfileCover(image: Data){
        spinner.startAnimating()
        firstly{
            ProfileModel.changeCover(image: image)
        }.done { [weak self] data in
            self?.spinner.stopAnimating()
            if data.message.lowercased() == "ok"{
                self?.profileCover.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self?.profileCover.sd_setImage(with: URL(string: data.data?.profileCover ?? ""), placeholderImage: UIImage())
            } else {
                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            print(error.localizedDescription)
            self?.spinner.stopAnimating()
        }
    }
    
    //MARK: REFERSH TABLE
    @objc func refreshData(){
        page = 1
        stories = []
        spinner.startAnimating()
        stories = []
        getStories(search: nil)
        viewWillAppear(true)
        profileTable.reloadData()
        refreshControl.endRefreshing()
    }
    
    //MARK: GET STORIES
    func getStories(search: String?){
        spinner.startAnimating()
        firstly{
            StoriesModel.fetchStories(hashtagId: hashtagId, page: page, userId: getProfile().id , search: search, isFavorite: nil, isSubscriptions: false)
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.stories = data.data
                self?.profileTable.reloadData()
            } else {
                self?.spinner.stopAnimating()
                //                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    
    //MARK: SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserProfile" {
            let destinationVC = segue.destination as! UserController
        } else if segue.identifier == "showComment" {
            let destinationVC = segue.destination as! CommentController
            destinationVC.story = viewStory!
        } else if segue.identifier == "complaintStory" {
            let destinationVC = segue.destination as! ComplaintController
            destinationVC.complaintType = 0
            destinationVC.culpritID = complaintId
        }
    }
    
    
    //MARK: HUG STORY
    @IBAction func hugStory(_ sender: UIButton){
        if !UserDefaults.standard.bool(forKey: "isRegistered") {
            view.makeToast("Чтобы поставить лайк истории необходимо зарегистрироваться")
            return
        }
        let hug = stories[sender.tag]?.hugged ?? false
        spinner.startAnimating()
        firstly{
            StoriesModel.hugStory(storyId: stories[sender.tag]?.id ?? 0, hugs: !hug)
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                
                self?.spinner.stopAnimating()
                self?.stories[sender.tag]?.hugged = !hug
                if ((self?.stories[sender.tag]?.hugged) == true) {
                    self?.stories[sender.tag]?.hugsCount! += 1
                } else {
                    self?.stories[sender.tag]?.hugsCount! -= 1
                }
                self?.profileTable.reloadRows(at: [IndexPath(row: sender.tag + 1, section: 0)], with: .none)
            } else {
                self?.spinner.stopAnimating()
                //                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }

    //MARK: HIDE STORY
    func hideStory(storyId: Int){
        spinner.startAnimating()
        firstly{
            StoriesModel.hideStory(storyId: storyId)
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.getStories(search: nil)
            } else {
                self?.spinner.stopAnimating()
                //                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    
    
    
    
    //MARK: DELETE STORY
    func deleteStory(storyId: Int){
        spinner.startAnimating()
        firstly{
            StoriesModel.deleteStory(storyId: storyId)
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.getStories(search: nil)
            } else {
                self?.spinner.stopAnimating()
                //                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    
    
    
    //MARK: SHOW FULL STORY
    @objc func showFullStory(_ sender: UIButton){
        if stories[sender.tag]!.fullText ?? false == true {
            stories[sender.tag]?.fullText = false
        } else {
            stories[sender.tag]?.fullText = true
        }
        profileTable.reloadRows(at: [IndexPath(row: sender.tag + 1, section: 0)], with: .automatic)
    }
    
    //MARK: SHOW COMMENT
    @IBAction func showComment(_ sender: UIButton) {
        if !UserDefaults.standard.bool(forKey: "isRegistered") {
            view.makeToast("Чтобы просматривать и оставлять комментарии необходимо зарегистрироваться")
            return
        }
        if sender.tag < stories.count {
            viewStory = stories[sender.tag]
            self.performSegue(withIdentifier: "showComment", sender: nil)
        }
    }
    
    

    
    //MARK: SHOW USER SITE
    @IBAction func goToWebsite(_ sender: UIButton){
        UIApplication.shared.open(URL(string: "http://" + (sender.titleLabel?.text?.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "") ?? ""))!, options: [:], completionHandler: nil)
    }
}



//MARK: TABLE
extension ProfileController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stories.count > 0 {
            return stories.count + 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let profileCell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileTableViewCell
            
            profileCell.configure(profile: getProfile(), myProfile: getProfile())
            
     
            return profileCell
        } else {
            
            if stories.count > 0 {
                
                
                let storyCell = tableView.dequeueReusableCell(withIdentifier: "storyCell", for: indexPath) as! StoryTableViewCell
                let transformer = SDImageResizingTransformer(size: CGSize(width: 500, height: 500), scaleMode: .aspectFill)
                storyCell.avatar.sd_setBackgroundImage(with: URL(string: stories[indexPath.row - 1]?.user?.avatar ?? ""), for: .normal, placeholderImage: UIImage(named: "Avatar"), options: [], context: [.imageTransformer: transformer])
                storyCell.avatar.tag = stories[indexPath.row - 1]?.user?.id ?? 0
                storyCell.name.setTitle((stories[indexPath.row - 1]?.user?.firstName ?? "") + " " + (stories[indexPath.row - 1]?.user?.lastName ?? ""), for: .normal)
                storyCell.name.tag = stories[indexPath.row - 1]?.user?.id ?? 0
                storyCell.actionButton.tag = stories[indexPath.row - 1]?.id ?? 0
                storyCell.userInfoStack.tag = stories[indexPath.row - 1]?.id ?? 0
                
                

                
                
                
                
                if stories[indexPath.row - 1]?.gallery.count == 0 && stories[indexPath.row - 1]?.video == nil {
                    storyCell.mediaCollecctionView.isHidden = true
                    storyCell.collectionViewConstraint.constant = 0
                } else {
                    storyCell.collectionViewConstraint.constant = 410
                    storyCell.mediaCollecctionView.isHidden = false
                }
                
                //hashtags
                if stories[indexPath.row - 1]?.hashtags.count == 0 {
                    storyCell.axasHashtags.isHidden = true
                } else {
                    storyCell.axasHashtags.isHidden = false
                    var hashtagText = ""
                    for hashtag in stories[indexPath.row - 1]?.hashtags ?? [] {
                        hashtagText = hashtagText + "#" + (hashtag?.text ?? "") + " "
                    }
                    hashtagText = hashtagText.replacingOccurrences(of: "##", with: "#")
                    storyCell.axasHashtags.text = hashtagText
                    storyCell.axasHashtags.resolveHashTags()
                    storyCell.axasHashtags.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "AccentColor")!]
                    storyCell.axasHashtags.font = UIFont(name: "Jost-Light", size: 18)
                }
                
                
                storyCell.readMoreButton.tag = indexPath.row - 1
                storyCell.readMoreButton.addTarget(self, action: #selector(showFullStory), for: .touchUpInside)
                if let body = stories[indexPath.row - 1]?.text {
                    //link in text
                    storyCell.storyText.isHidden = false
                    
                    if stories[indexPath.row - 1]?.fullText == true {
                        storyCell.storyText.attributedText = SwiftyMarkdown(string: body).attributedString()
                        storyCell.readMoreButton.isHidden = false
                        storyCell.readMoreButton.setTitle("Скрыть", for: .normal)
                    } else {
                        storyCell.readMoreButton.setTitle("Смотреть полностью...", for: .normal)
                        if body.count > 250 {
                            //                            storyCell.storyText.text = String(body.prefix(250)) + "..."
                            storyCell.storyText.attributedText = SwiftyMarkdown(string: String(body.prefix(250)) + "...").attributedString()
                            storyCell.readMoreButton.isHidden = false
                        } else {
                            storyCell.storyText.attributedText = SwiftyMarkdown(string: body).attributedString()
                            storyCell.readMoreButton.isHidden = true
                        }
                    }
                } else {
                    storyCell.storyText.isHidden = true
                }
                
                
                if !UserDefaults.standard.bool(forKey: "isRegistered") {
                    storyCell.actionButton.isHidden = true
                } else {
                    storyCell.actionButton.isHidden = false
                }
                
                storyCell.actionButton.menu = UIMenu(children : [
                    UIAction(title : "Удалить", image: UIImage(systemName: "trash"), handler: {_ in self.deleteStory(storyId: self.stories[indexPath.row - 1]?.id ?? 0)})])
                storyCell.actionButton.showsMenuAsPrimaryAction = true
                
                storyCell.date.text = stories[indexPath.row - 1]?.created?.toDay
                storyCell.hugCount.text = "\(stories[indexPath.row - 1]?.hugsCount ?? 0)"
                storyCell.hugButton.tag = indexPath.row - 1
                storyCell.commentButton.tag = indexPath.row - 1
                if stories[indexPath.row - 1]?.hugged == true{
                    storyCell.hugButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                } else {
                    storyCell.hugButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                }
                
                
                storyCell.pageControl.numberOfPages = stories[indexPath.row - 1]?.gallery.count ?? 0
                
                storyCell.story = stories[indexPath.row - 1]
                
                storyCell.reloadCollectionView()
                
                if let cell = storyCell.mediaCollecctionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? StoryImageCollectionViewCell {
                    cell.playButton.isHidden = true
                    cell.playButton.tintColor = .cyan
                    storyCell.reloadCollectionView()
                }
                
                return storyCell
            } else {
                let emptyCell = tableView.dequeueReusableCell(withIdentifier: "enptyStoriesCell", for: indexPath) as! EmptyStoriesTableViewCell
                
                return emptyCell
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let profileCell = tableView(profileTable, cellForRowAt: IndexPath(row: 0, section: 0)) as! ProfileTableViewCell
        
        if scrollView.contentOffset.y >= 160 && scrollView.contentOffset.y < 200 {
            UIView.animate(withDuration: 1) {
                self.secondAvatarImage.alpha = 1
                self.secondAvatarView.alpha = 1
            }
        } else if scrollView.contentOffset.y > 100 && scrollView.contentOffset.y < 160{
            UIView.animate(withDuration: 1) {
                self.secondAvatarImage.alpha = 0
                self.secondAvatarView.alpha = 0
            }
        } else if scrollView.contentOffset.y < 0 {
            profileCoverHeight.constant = 236 + (scrollView.contentOffset.y * -1)
        } else {
            profileCoverHeight.constant = 236
        }
    }

    
}

//MARK: - StoryTableViewCellDelegate
extension ProfileController: StoryTableViewCellDelegate {
    func getImageURL(imageUrl: String?) {
        if imageUrl != nil && imageUrl != "" {
            let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            let copyBufferAction = UIAlertAction(title: "Сохранить изображение", style: .default) { [weak self] _ in
                let imageSaved = UIImageView()
                imageSaved.sd_setImage(with: URL(string: imageUrl ?? ""), placeholderImage: UIImage()) { image, Error, _, _ in
                    UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                }
                self?.view.makeToast("Изображение сохранено")
            }
            actionController.addAction(copyBufferAction)
            actionController.addAction(cancelAction)
            present(actionController, animated: true)
        }
    }
    
    
}


//MARK: WORK WITH IMAGE
extension ProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        self.changeProfileCover(image: ((info[.editedImage] as? UIImage)?.pngData())!)
        dismiss(animated: true)
    }
}
