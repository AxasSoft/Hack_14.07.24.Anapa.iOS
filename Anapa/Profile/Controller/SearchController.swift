//
//  SearchController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 21.06.2023.
//

import UIKit
import PromiseKit
import Toast_Swift
import SDWebImage
import SwiftyMarkdown

class SearchController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var peopleButton: UIButton!
    @IBOutlet weak var storiesButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var searchTF: UITextField!
    var searchString = ""
    var users: [Profile?] = []
    var page = 1
    var selectUser: Profile?
    var hasNext = false
    
    var selectInfo: [Info?] = []
    
    var searchCategory = 0
    var paginator: Paginator?
    
    var infoPage = 1
    var infoPaginator: Paginator?
    
    var stories: [Story?] = []
    var userId: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTF.delegate = self
        peopleButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        searchUsers()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        page = 1
        users = []
        
        filterButton.addRadius()
        storiesButton.addRadius()
        peopleButton.addRadius()
    }
    
    //MARK: CHANGE SEARCH CATEGORY
    @IBAction func searchButtonTap(_ sender: UIButton){
        page = 1
        users = []
        selectInfo = []
        stories = []
        peopleButton.setTitleColor(UIColor(named: "GreyText"), for: .normal)
        storiesButton.setTitleColor(UIColor(named: "GreyText"), for: .normal)
        infoButton.setTitleColor(UIColor(named: "GreyText"), for: .normal)
        
        peopleButton.backgroundColor = UIColor.white
        storiesButton.backgroundColor = UIColor.white
        infoButton.backgroundColor = UIColor.white
        switch sender {
        case peopleButton:
            peopleButton.setTitleColor(UIColor.white, for: .normal)
            peopleButton.backgroundColor = UIColor(named: "AccentColor")
            searchUsers()
            filterButton.isHidden = false
            searchCategory = 0
        case infoButton:
            infoButton.setTitleColor(UIColor.white, for: .normal)
            infoButton.backgroundColor = UIColor(named: "AccentColor")
            fetchInfoBlocks(category: nil, search: searchString, infoPage: infoPage)
            filterButton.isHidden = true
            searchCategory = 1
        case storiesButton:
            storiesButton.setTitleColor(UIColor.white, for: .normal)
            storiesButton.backgroundColor = UIColor(named: "AccentColor")
            getStories(search: searchString, page: 1, userId: userId)
            filterButton.isHidden = true
            searchCategory = 2
        default:
            peopleButton.setTitleColor(UIColor.white, for: .normal)
            peopleButton.backgroundColor = UIColor(named: "AccentColor")
            searchUsers()
            filterButton.isHidden = false
            searchCategory = 0
        }
        
    }
    
    
    
    @IBAction func close(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if searchTF.text!.count >= 3 {
            searchString = searchTF.text!
            page = 1
        } else {
            searchString = ""
            page = 1
            
        }
        users = []
        selectInfo = []
        stories = []
        switch searchCategory{
        case 0:
            searchUsers()
        case 1:
            fetchInfoBlocks(category: nil, search: searchString, infoPage: infoPage)
        case 2:
            getStories(search: searchString, page: 1, userId: userId)
        default:
            searchUsers()
        }
    }
    
    //MARK: SHOW FILTER
    @IBAction func showFilter(_ sender: UIButton){
        let sBoard = UIStoryboard(name: "Profile", bundle: .main)
        guard let controller = sBoard.instantiateViewController(withIdentifier: "searchFilterVC") as? SearchFilterController  else { return }
        controller.modalPresentationStyle = .fullScreen
        self.presentPanModal(controller)
    }
    
    
    // MARK: SEARCH USER
    func searchUsers(){
        spinner.startAnimating()
        firstly{
            ProfileModel.searchUser(search: searchString, page: page, isBusiness: nil, distance: nil, lat: nil, lon: nil, categoryIds: [])
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                for user in data.data {
                    self?.users.append(user)
                }
                
                self?.hasNext = data.meta?.paginator?.hasNext ?? false
                self?.searchTable.reloadData()
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast("Не удалось никого найти. Попробуйте изменить параметры поиска.")
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            self?.view.makeToast("Не удалось никого найти. Попробуйте изменить параметры поиска.")
        }
    }
    
    //MARK: SEARCH INFOS
    func fetchInfoBlocks(category: Int?, search: String?, infoPage: Int){
        spinner.startAnimating()
        firstly{
            InfoModel.fetchInfoBlocks(category: category, search: search?.trimmingCharacters(in: .whitespacesAndNewlines), page: infoPage)
        }.done { [weak self] data in
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.selectInfo += data.data
                self?.selectInfo = self?.selectInfo.uniqued() ?? []
                self?.infoPaginator = data.meta?.paginator
                //                self?.selectInfo = []
                //                self?.selectCategory()
                //                self?.categoriesCollection.scrollToItem(at: IndexPath(item: self?.selectCategoryId ?? 0, section: 0), at: .centeredHorizontally, animated: false)
                //                self?.categoriesCollection.reloadData()
                self?.searchTable.reloadData()
                if (self?.selectInfo.count ?? 0) > 0 {
                    self?.searchTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
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
    
    //MARK: GET STORIES
    func getStories(search: String?, page: Int, userId: Int?){
        spinner.startAnimating()
        firstly{
            StoriesModel.fetchStories(hashtagId: nil, page: page, userId: userId, search: search, isFavorite: nil, isSubscriptions: false)
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.stories += data.data
                self?.stories = self?.stories.uniqued() ?? []
                self?.paginator = data.meta?.paginator
                self?.searchTable.reloadData()
                self?.searchTable.scrollsToTop
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.errorDescription)
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
        searchTable.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .automatic)
    }
    
    //MARK: SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUser"{
            let destinationVC = segue.destination as! UserController
            destinationVC.user = selectUser
            destinationVC.userId = selectUser?.id
        }
    }
}


//MARK: TABLE
extension SearchController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch searchCategory{
        case 0:
            return users.count
        case 1:
            return selectInfo.count
        case 2:
            return stories.count
        default:
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchCategory == 0 {
            let userCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserInfoTableViewCell
            
            userCell.avatar.sd_imageIndicator = SDWebImageActivityIndicator.gray
            userCell.avatar.sd_setImage(with: URL(string: users[indexPath.row]?.avatar ?? ""), placeholderImage: UIImage(named: "Avatar"))
            
            userCell.name.text = (users[indexPath.row]?.firstName ?? "") + " " + (users[indexPath.row]?.lastName ?? "")
            userCell.lastVisit.text = users[indexPath.row]?.lastVisitedHuman
            
            if indexPath.row == users.count - 1 && hasNext {
                page += 1
                searchUsers()
            }
            return userCell
        }  else if searchCategory == 1 {
            let infoCell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! InfoBlockTableViewCell
            if selectInfo.count > indexPath.row {
                if selectInfo[indexPath.row]?.image == nil {
                    infoCell.cover.isHidden = true
                } else {
                    infoCell.cover.isHidden = false
                    infoCell.cover.sd_setImage(with: URL(string: selectInfo[indexPath.row]?.image ?? ""), placeholderImage: UIImage(named: ""))
                }
                
                infoCell.titleLabel.text = selectInfo[indexPath.row]?.title ?? ""
                infoCell.body.text = selectInfo[indexPath.row]?.body ?? ""
                
                //get next info
                let hasNext = infoPaginator?.hasNext ?? true
                if indexPath.row == stories.count - 1 && hasNext {
                    self.infoPage += 1
                    fetchInfoBlocks(category: nil, search: searchString, infoPage: infoPage)
                }
            }
            
            return infoCell
        }   else {
            
            if stories.count > 0 {
                
                
                let storyCell = tableView.dequeueReusableCell(withIdentifier: "storyCell", for: indexPath) as! StoryTableViewCell
                let transformer = SDImageResizingTransformer(size: CGSize(width: 500, height: 500), scaleMode: .aspectFill)
                storyCell.avatar.sd_setBackgroundImage(with: URL(string: stories[indexPath.row]?.user?.avatar ?? ""), for: .normal, placeholderImage: UIImage(named: "Avatar"), options: [], context: [.imageTransformer: transformer])
                storyCell.avatar.tag = stories[indexPath.row]?.user?.id ?? 0
                storyCell.name.setTitle((stories[indexPath.row]?.user?.firstName ?? "") + " " + (stories[indexPath.row]?.user?.lastName ?? ""), for: .normal)
                storyCell.name.tag = stories[indexPath.row]?.user?.id ?? 0
                storyCell.actionButton.tag = stories[indexPath.row]?.id ?? 0
                storyCell.userInfoStack.tag = stories[indexPath.row]?.id ?? 0
//                storyCell.userInfoStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showUserProfile)))
                
                
                
                
                
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
//                    searchString = nil
                    getStories(search: searchString, page: page, userId: userId)
                }
                
                return storyCell
            } else {
                let emptyCell = tableView.dequeueReusableCell(withIdentifier: "enptyStoriesCell", for: indexPath) as! EmptyStoriesTableViewCell
                
                return emptyCell
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchCategory == 0 {
            if indexPath.row < users.count {
                selectUser = users[indexPath.row]
                performSegue(withIdentifier: "showUser", sender: nil)
            }
        } else {
            if indexPath.row < selectInfo.count {
                let sBoard = UIStoryboard(name: "Info", bundle: .main)
                let vc = sBoard.instantiateViewController(withIdentifier: "OneInfoVC") as! OneInfoController
                vc.info = selectInfo[indexPath.row]
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
        }
        
    }
    
}


//MARK: - StoryTableViewCellDelegate
extension SearchController: StoryTableViewCellDelegate {
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
