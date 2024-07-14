//
//  InfoContainerController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 22.01.2023.
//

import UIKit
import PromiseKit
import Toast_Swift
import SDWebImage
import SwiftyMarkdown

class InfoContainerController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var categoriesCollection: UICollectionView!
    @IBOutlet weak var infoTable: UITableView!
    
    let categories = Constants.infoCategory
    var selectCategoryId = 0
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var infoBLocks: [Info?] = []
    var aboutInfo: [Info?] = []
    var visaInfo: [Info?] = []
    var importantInfo: [Info?] = []
    
    var selectInfo: [Info?] = []
    
    var page = 1
    var paginator: Paginator?
    
    @IBOutlet weak var searchNavbarButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var closeSearchButton: UIButton!
    @IBOutlet weak var topView: UIView!
    var searchString: String?
    
    
    @IBOutlet weak var collectionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonStackForModal: UIStackView!
    
    var hiddenTop = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchString = nil
        infoTable.delegate = self
        infoTable.dataSource = self
        categoriesCollection.delegate = self
        categoriesCollection.dataSource = self
        
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
        selectInfo = []
        selectCategoryId = infoSelect
        infoBLocks = []
        
        selectCategory()
        
        fetchInfoBlocks(category: selectCategoryId, search: nil, page: page)
        //hide search
        searchView.isHidden = true
        self.searchTF.isHidden = true
        self.closeSearchButton.isHidden = true
        
        searchTF.delegate = self
        searchTF.addTarget(self, action: #selector(searchEndEditing), for: .editingDidEnd)
    }
    
    
    @IBAction func close(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: SHOW SEARCH
    @IBAction func showSearch(_ sender: UIButton){
        searchString = nil
        if !searchTF.isHidden {
            searchTF.text = ""
            fetchInfoBlocks(category: selectCategoryId, search: nil, page: page)
        }
        
        self.searchTF.isHidden = !self.searchTF.isHidden
        self.closeSearchButton.isHidden = !self.closeSearchButton.isHidden
        UIView.transition(with: searchView, duration: 0.4,
                          options: .curveEaseInOut,
                          animations: {
            self.searchView.isHidden = !self.searchView.isHidden
        })
        
    }
    
    //MARK: SEARCH INFO
    @objc func searchEndEditing(_ textField: UITextField) {
        if searchTF.text?.count ?? 0 >= 3 {
            selectInfo = []
            infoTable.reloadData()
            searchString = searchTF.text!
            //            fetchInfoBlocks(category: infoSelect, search: textField.text)
            fetchInfoBlocks(category: nil, search: textField.text, page: page)
        } else {
            selectInfo = []
            searchString = nil
            fetchInfoBlocks(category: nil, search: searchString, page: page)
        }
    }
    
    
    //MARK: SELECT CATEGORY
    func selectCategory(){
        infoSelect = selectCategoryId
        selectInfo = []
        fetchInfoBlocks(category: selectCategoryId, search: searchString, page: page)
        
        
        
        infoTable.reloadData()
    }
    
    //MARK: GET INFOS
    func fetchInfoBlocks(category: Int?, search: String?, page: Int?){
        spinner.startAnimating()
        firstly{
            InfoModel.fetchInfoBlocks(category: category, search: search?.trimmingCharacters(in: .whitespacesAndNewlines), page: page)
        }.done { [weak self] data in
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.infoBLocks += data.data
                self?.infoBLocks = self?.infoBLocks.uniqued() ?? []
                self?.selectInfo = []
                if self?.searchString != "" && self?.searchString != nil{
                    self?.infoBLocks = data.data
                    for info in self?.infoBLocks ?? [] {
                        self?.selectInfo.append(info)
                    }
                } else {
                    for info in self?.infoBLocks ?? [] {
                        if info?.category == infoSelect {
                            self?.selectInfo.append(info)
                        }
                    }
                }
                self?.categoriesCollection.scrollToItem(at: IndexPath(item: self?.selectCategoryId ?? 0, section: 0), at: .centeredHorizontally, animated: false)
                self?.categoriesCollection.reloadData()
                self?.paginator = data.meta?.paginator
                self?.infoTable.reloadData()
                if (self?.selectInfo.count ?? 0) > 0 {
                    self?.infoTable.reloadData()
                    self?.infoTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
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



//MARK: TABLE
extension InfoContainerController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let infoCell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! InfoBlockTableViewCell
        if selectInfo.count > indexPath.row {
            if selectInfo[indexPath.row]?.image == nil {
                infoCell.cover.isHidden = true
            } else {
                infoCell.cover.isHidden = false
                infoCell.cover.sd_setImage(with: URL(string: selectInfo[indexPath.row]?.image ?? ""), placeholderImage: UIImage(named: ""))
            }
            infoCell.date.text = selectInfo[indexPath.row]?.created?.toDay ?? ""
            infoCell.titleLabel.text = selectInfo[indexPath.row]?.title ?? ""
            infoCell.body.attributedText = SwiftyMarkdown(string: selectInfo[indexPath.row]?.body ?? "").attributedString()
            infoCell.body.contentInset = UIEdgeInsets(top: -8, left: -4, bottom: -8, right: -4)
            
            //get next info
            let hasNext = paginator?.hasNext ?? true
            if indexPath.row == selectInfo.count - 1 && hasNext {
                self.page += 1
                searchString = nil
                fetchInfoBlocks(category: selectCategoryId, search: searchString, page: page)
            }
        }
        
        return infoCell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < selectInfo.count {
            let sBoard = UIStoryboard(name: "Info", bundle: .main)
            let vc = sBoard.instantiateViewController(withIdentifier: "OneInfoVC") as! OneInfoController
            vc.info = selectInfo[indexPath.row]
            show(vc, sender: nil)
        }
    }
}

//MARK: COLLECTION
extension InfoContainerController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! InfoCategoryCollectionViewCell
        
        categoryCell.category.text = categories[indexPath.item].name
        
        if selectCategoryId == categories[indexPath.item].id {
            categoryCell.backView.backgroundColor = UIColor(named: "AccentColor")
            categoryCell.category.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            categoryCell.category.textColor = UIColor.white
        } else {
            categoryCell.backView.backgroundColor = UIColor.white
            categoryCell.category.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            categoryCell.category.textColor = UIColor(named: "Label")
        }
        
        
        return categoryCell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: (view.frame.width - 44) / 2, height: 190)
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if indexPath.item < categories.count {
            selectCategoryId = categories[indexPath.item].id
            categoriesCollection.reloadData()
            selectCategory()
        }
    }
}

