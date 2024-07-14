//
//  StoriesController.swift
//  NotAlone
//
//  Created by Сергей Майбродский on 19.04.2022.
//

import UIKit
import PromiseKit
import Toast_Swift
import SDWebImage
import SwiftyMarkdown
import NotificationView
import MessageKit
import UIActiveableLabel
//import AppTrackingTransparency

class StoriesController: UIViewController, UITabBarDelegate, UITextFieldDelegate, UITextViewDelegate, UIActiveableLabelDelegate {
    func didSelect(_ text: String, type: UIActiveableType) {
    }
    
    
    
    let collectionMargin = CGFloat(16)
    let itemSpacing = CGFloat(10)
    let itemHeight = CGFloat(322)
    
    var itemWidth = CGFloat(0)
    
    
    var storedOffsets = [Int: CGFloat]()
//    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var storiesTable: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var refreshControl = UIRefreshControl()
    
    var showFavorites = false
    var hashtagId: Int?
    var page = 1
    var paginator: Paginator?
    var searchString: String?
    var isFavorite: Bool?
    var userId: Int?
    var viewProfileId: Int?
    var stories: [Story?] = []
    var profile: Profile?
    var viewStory: Story?
    var complaintId: Int?
    var isSubscriptions: Bool = false
    
    
    @IBOutlet weak var createStoryButton: UIButton!
    @IBOutlet weak var searchNavbarButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var closeSearchButton: UIButton!
    @IBOutlet weak var subscribersButton: UIButton!
    @IBOutlet weak var recomendationButton: UIButton!
    @IBOutlet weak var topView: UIView!
    
    //for main modal
    @IBOutlet weak var collectionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonStackForModal: UIStackView!
    var hiddenTop = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recomendationButton.setTitleColor(UIColor.white, for: .normal)
        recomendationButton.backgroundColor = UIColor(named: "AccentColor")
        
        if hiddenTop {
            collectionTopConstraint.constant = -84
            topView.isHidden = true
            buttonStackForModal.isHidden = false
        } else {
            buttonStackForModal.isHidden = true
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.bool(forKey: "isRegistered") == false {
            createStoryButton.isHidden = true
        } else {
            createStoryButton.isHidden = false
        }
        profile = getProfile()
        setupUI()
        searchString = nil
        if paginator == nil {
            getStories(search: searchString, page: page, userId: userId)
        }
        
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = true
    }
    
    
    func setupUI(){
        spinner.stopAnimating()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Потяните вниз чтобы обновить")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        storiesTable.addSubview(refreshControl)
        
        //hide search
        searchView.isHidden = true
        self.searchTF.isHidden = true
        self.closeSearchButton.isHidden = true
        
        searchTF.delegate = self
        searchTF.addTarget(self, action: #selector(searchEndEditing), for: .editingDidEnd)
        
        createStoryButton.addRadius()
        

        subscribersButton.addRadius()
        recomendationButton.addRadius()
    
    }
    
    
    //MARK: CHANGE FEED CATEGORY
    @IBAction func changeFeed(_ sender: UIButton){
        subscribersButton.setTitleColor(UIColor.black, for: .normal)
        subscribersButton.backgroundColor = UIColor.white
        recomendationButton.setTitleColor(UIColor.black, for: .normal)
        recomendationButton.backgroundColor = UIColor.white
        if sender == subscribersButton {
            subscribersButton.setTitleColor(UIColor.white, for: .normal)
            subscribersButton.backgroundColor = UIColor(named: "AccentColor")
            isSubscriptions = true
        } else {
            recomendationButton.setTitleColor(UIColor.white, for: .normal)
            recomendationButton.backgroundColor = UIColor(named: "AccentColor")
            isSubscriptions = false
        }
        stories = []
        storiesTable.reloadData()
        getStories(search: searchString, page: page, userId: userId)
    }
    
    //MARK: SEARCH FEED
    @objc func searchEndEditing(_ textField: UITextField) {
        if searchTF.text?.count ?? 0 >= 3 {
            stories = []
            searchString = searchTF.text!
            getStories(search: searchString, page: page, userId: userId)
            storiesTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
        } else {
            stories = []
            searchString = nil
            getStories(search: searchString, page: page, userId: userId)
            storiesTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
        }
    }
    
    
    //MARK: SHOW FAVORITES
    @IBAction func showFavorites(_ sender: UIButton){
        if !UserDefaults.standard.bool(forKey: "isRegistered") {
            view.makeToast("Для просмотра и добавления историй в избранное необходимо зарегистрироваться")
            return
        }
        showFavorites = !showFavorites
        if showFavorites {
//            favoritesButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            isFavorite = true
        } else {
//            favoritesButton.setImage(UIImage(systemName: "star"), for: .normal)
            isFavorite = nil
        }
        stories = []
        getStories(search: searchString, page: page, userId: userId)
    }
    
    //MARK: SHOW SEARCH
    @IBAction func showSearch(_ sender: UIButton){
        if !searchTF.isHidden {
            searchTF.text = ""
            stories = []
            searchString = nil
            getStories(search: searchString, page: page, userId: userId)
        }
        
        self.searchTF.isHidden = !self.searchTF.isHidden
        self.closeSearchButton.isHidden = !self.closeSearchButton.isHidden
        UIView.transition(with: searchView, duration: 0.4,
                          options: .curveEaseInOut,
                          animations: {
            self.searchView.isHidden = !self.searchView.isHidden
        })
        
    }
    
    //MARK: REFERSH TABLE
    @objc func refreshData(){
        page = 1
        stories = []
        spinner.startAnimating()
        stories = []
        searchString = nil
        getStories(search: searchString, page: page, userId: userId)
        viewWillAppear(true)
        storiesTable.reloadData()
        refreshControl.endRefreshing()
    }
    
    //MARK: GET STORIES
    func getStories(search: String?, page: Int, userId: Int?){
        spinner.startAnimating()
        firstly{
            StoriesModel.fetchStories(hashtagId: hashtagId, page: page, userId: userId, search: search, isFavorite: isFavorite, isSubscriptions: isSubscriptions)
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.stories += data.data
                self?.stories = self?.stories.uniqued() ?? []
                self?.paginator = data.meta?.paginator
                self?.storiesTable.reloadData()
                self?.storiesTable.scrollsToTop
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    
    //MARK: SHOW PROFILE
    @IBAction func showUserProfile(_ sender: UIButton){
        if !UserDefaults.standard.bool(forKey: "isRegistered") {
            view.makeToast("Для просмотра профиля необходимо зарегистрироваться")
            return
        }
        if sender.tag == 0{
            view.makeToast("Ошибка получения профиля")
            return
        }
        if sender.tag == profile?.id {
            let sBoard = UIStoryboard(name: "Profile", bundle: .main)
            let vc = sBoard.instantiateInitialViewController() as! ProfileController
            self.show(vc, sender: nil)
            return
        }
        viewProfileId = sender.tag
        self.performSegue(withIdentifier: "showUserProfile", sender: nil)
    }
    
    //MARK: SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserProfile" {
            let destinationVC = segue.destination as! UserController
            destinationVC.userId = viewProfileId!
        } else if segue.identifier == "showComment" {
            let destinationVC = segue.destination as! CommentController
            destinationVC.story = viewStory!
        } else if segue.identifier == "complaintStory" {
            let destinationVC = segue.destination as! ComplaintController
            destinationVC.complaintType = 0
            destinationVC.culpritID = complaintId
        }
    }
    
    
    //MARK: STORY ACTION
    @IBAction func storyAction(_ sender: UIButton){
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Закрыть", style: .cancel)
        let hideAction = UIAlertAction(title: "Скрыть", style: .default) { [weak self] _ in
            self?.hideStory(storyId: sender.tag)
        }
        //        let blockAction = UIAlertAction(title: "Заблокировать", style: .default) { [weak self] _ in
        //
        //        }
        let claimAction = UIAlertAction(title: "Пожаловаться", style: .default) { [weak self]_ in
            self?.complaintId = sender.tag
            self?.performSegue(withIdentifier: "complaintStory", sender: nil)
        }
        actionController.addAction(hideAction)
        //        actionController.addAction(blockAction)
        actionController.addAction(claimAction)
        actionController.addAction(cancelAction)
        present(actionController, animated: true)
    }
    
    func goComplaint(){
        
        
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
                self?.storiesTable.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    
    //MARK: FAVORITE STORY
    @IBAction func favoriteStory(_ sender: UIButton){
        if !UserDefaults.standard.bool(forKey: "isRegistered") {
            view.makeToast("Чтобы добавить историю в избранное необходимо зарегистрироваться")
            return
        }
        let isFavorite = stories[sender.tag]?.isFavorite ?? false
        spinner.startAnimating()
        firstly{
            StoriesModel.favoriteStory(storyId: stories[sender.tag]?.id ?? 0, favorite: !isFavorite)
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                
                self?.spinner.stopAnimating()
                self?.stories[sender.tag]?.isFavorite = !isFavorite
                self?.storiesTable.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    
    
    //MARK: HIDE STORY
    func hideStory(storyId: Int){
        if UserDefaults.standard.bool(forKey: "isRegistered") == false {
            view.makeToast("Чтобы скрыть историю необходимо зарегистрироваться")
            return
        }
        spinner.startAnimating()
        firstly{
            StoriesModel.hideStory(storyId: storyId)
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.searchString = nil
                self?.getStories(search: self?.searchString, page: self?.page ?? 1, userId: self?.userId)
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    
    
    //MARK: SEARCH HASHTAG
//    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//        guard let axasTextView = textView as? AxasHashtagTextView  else { return false }
//        
//        stories = []
//        searchTF.text = "#\(axasTextView.hashtagArr?[Int(url.absoluteString.replacingOccurrences(of: ":", with: ""))!] ?? "")"
//        if searchTF.isHidden {
//            self.searchTF.isHidden = !self.searchTF.isHidden
//            self.closeSearchButton.isHidden = !self.closeSearchButton.isHidden
//            UIView.transition(with: searchView, duration: 0.4,
//                              options: .curveEaseInOut,
//                              animations: {
//                self.searchView.isHidden = !self.searchView.isHidden
//            })
//        }
//        searchString = axasTextView.hashtagArr?[Int(url.absoluteString.replacingOccurrences(of: ":", with: ""))!] ?? ""
//        getStories(search: searchString, page: page, userId: userId)
//        if stories.count > 0 {
//            storiesTable.reloadData()
//            if storiesTable.numberOfRows(inSection: 0) ?? 0 > 0  {
//                storiesTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
//            }
//        }
//        return true
//    }
    
    
    //MARK: SHOW FULL STORY
    @objc func showFullStory(_ sender: UIButton){
        if stories[sender.tag]!.fullText ?? false == true {
            stories[sender.tag]?.fullText = false
        } else {
            stories[sender.tag]?.fullText = true
        }
        storiesTable.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .automatic)
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
    
}


//MARK: TABLE VIEW
extension StoriesController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stories.count > 0 {
            return stories.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if stories.count > 0 {
            
            
            let storyCell = tableView.dequeueReusableCell(withIdentifier: "storyCell", for: indexPath) as! StoryTableViewCell
            let transformer = SDImageResizingTransformer(size: CGSize(width: 500, height: 500), scaleMode: .aspectFill)
            storyCell.avatar.sd_setBackgroundImage(with: URL(string: stories[indexPath.row]?.user?.avatar ?? ""), for: .normal, placeholderImage: UIImage(named: "Avatar"), options: [], context: [.imageTransformer: transformer])
            storyCell.avatar.tag = stories[indexPath.row]?.user?.id ?? 0
            storyCell.name.setTitle((stories[indexPath.row]?.user?.firstName ?? "") + " " + (stories[indexPath.row]?.user?.lastName ?? ""), for: .normal)
            storyCell.name.tag = stories[indexPath.row]?.user?.id ?? 0
            storyCell.actionButton.tag = stories[indexPath.row]?.id ?? 0
            storyCell.userInfoStack.tag = stories[indexPath.row]?.id ?? 0
            storyCell.userInfoStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showUserProfile)))
            
            
            
            
            
            if stories[indexPath.row]?.gallery.count == 0 && stories[indexPath.row]?.video == nil {
                storyCell.mediaCollecctionView.isHidden = true
                storyCell.collectionViewConstraint.constant = 0
            } else {
                storyCell.collectionViewConstraint.constant = 410
                storyCell.mediaCollecctionView.isHidden = false
            }
            
            //hashtags
            if stories[indexPath.row]?.hashtags.count == 0 {
                storyCell.axasHashtags.isHidden = true
            } else {
                storyCell.axasHashtags.isHidden = false
                var hashtagText = ""
                for hashtag in stories[indexPath.row]?.hashtags ?? [] {
                    hashtagText = hashtagText + "#" + (hashtag?.text ?? "") + " "
                }
                hashtagText = hashtagText.replacingOccurrences(of: "##", with: "#")
                storyCell.axasHashtags.text = hashtagText
                storyCell.axasHashtags.delegate = self
                storyCell.axasHashtags.resolveHashTags()
                storyCell.axasHashtags.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "AccentColor")!]
                storyCell.axasHashtags.font = UIFont(name: "Jost-Light", size: 18)
            }
            
            
            storyCell.readMoreButton.tag = indexPath.row
            storyCell.readMoreButton.addTarget(self, action: #selector(showFullStory), for: .touchUpInside)
            if let body = stories[indexPath.row]?.text {
                
                //link in text
                storyCell.storyText.isHidden = false
                storyCell.storyText.delegate = self
                storyCell.storyText.tag = indexPath.row

                
                if stories[indexPath.row]?.fullText == true {
                    storyCell.storyText.attributedText = SwiftyMarkdown(string: body).attributedString()
                    storyCell.readMoreButton.isHidden = false
                    storyCell.readMoreButton.setTitle("Скрыть", for: .normal)
                } else {
                    storyCell.readMoreButton.setTitle("Смотреть полностью...", for: .normal)
                    if body.count > 250 {
//                        storyCell.storyText.text = String(body.prefix(250)) + "..."
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
            
            storyCell.date.text = stories[indexPath.row]?.created?.toDay
            storyCell.hugCount.text = "\(stories[indexPath.row]?.hugsCount ?? 0)"
            storyCell.hugButton.tag = indexPath.row
            storyCell.commentButton.tag = indexPath.row
            if stories[indexPath.row]?.hugged == true{
                storyCell.hugButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            } else {
                storyCell.hugButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
            
            storyCell.pageControl.numberOfPages = stories[indexPath.row]?.gallery.count ?? 0
            
            storyCell.story = stories[indexPath.row]
            
            storyCell.reloadCollectionView()
            storyCell.delegate = self
            
            if let cell = storyCell.mediaCollecctionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? StoryImageCollectionViewCell {
                cell.playButton.isHidden = true
                cell.playButton.tintColor = .cyan
                storyCell.reloadCollectionView()
            }
            
            //get next news
            let hasNext = paginator?.hasNext ?? true
            if indexPath.row == stories.count - 1 && hasNext {
                self.page += 1
                searchString = nil
                getStories(search: searchString, page: page, userId: userId)
            }
            
            return storyCell
        } else {
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: "enptyStoriesCell", for: indexPath) as! EmptyStoriesTableViewCell
            
            return emptyCell
        }
    }
}
//MARK: - StoryTableViewCellDelegate
extension StoriesController: StoryTableViewCellDelegate {
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

class CustomTapGestureRecognizer: UILongPressGestureRecognizer {
    var text: String?
}
