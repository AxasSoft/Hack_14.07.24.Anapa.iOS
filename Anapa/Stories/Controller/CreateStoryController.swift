//
//  CreateStoryController.swift
//  NotAlone
//
//  Created by Сергей Майбродский on 27.06.2022.
//

import UIKit
import PromiseKit
import Toast_Swift
import ZLPhotoBrowser
import Photos
import YPImagePicker
import SwiftUI

class CreateStoryController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var textTV: UITextView!
    @IBOutlet weak var hashtagsTF: UITextField!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var addHashtagButton: UIButton!
    
    
    let picker = YPImagePicker()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedImages: [UIImage] = []
    var croppedImages: [UIImage] = []
    
    var selectedAssets: [PHAsset] = []
    
    var isOriginal = false
    
    var galleryId: [Int] = []
    var videoURL = ""
    var videoId: Int?
    var hashtags: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    func setupUI(){
        nextButton.addSmallRadius()
        spinner.stopAnimating()
        addPhotoButton.setOval()
        addHashtagButton.setOval()
    }
    
    @IBAction func close(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editingHashtagTF(_ sender: UIButton){
        hashtagsTF.becomeFirstResponder()
    }
    
    
    //MARK: CHECK STORY DATA
    @IBAction func publicationStory(_ sender: UIButton){
        if hashtagsTF.text?.count == 0 {
            self.view.makeToast("Добавьте минимум один хэштег")
            return
        } else {
            // remove duplicate and empty
            hashtags = Array(Set(hashtagsTF.text!.replacingOccurrences(of: ",", with: "#").replacingOccurrences(of: " ", with: "#").components(separatedBy: "#").filter {$0 != ""}))
        }
        if textTV.text.count == 0 && selectedAssets.count == 0 {
            self.view.makeToast("Нельзя опубликовать историю без контента")
            return
        }
        var videosCount = 0
        for selectedAsset in selectedAssets {
            if selectedAsset.mediaType == .video {
                videosCount += 1
                if selectedAsset.duration > 60 {
                    view.makeToast("Длительность видео в истории не может быть больше 60 секунд")
                    return
                }
            }
        }
        if videosCount > 1 {
            self.view.makeToast("История может содержать только одно видео длительностью не более 60 секунд")
            return
        }
        
        if selectedAssets.count == 0 {
            createStory()
        } else {
            addAttachment()
        }
    }
    

    

    
    //MARK: SEND ATTACHMENT
    func addAttachment(){
        for selectedAsset in selectedAssets {
            if selectedAsset.mediaType == .video {
                PHImageManager.default().requestAVAsset(forVideo: selectedAsset,
                                                        options: nil) { (asset, audioMix, info) in
                    if let asset = asset as? AVURLAsset {
                        do {
                            let media = try NSData(contentsOfFile: "\(asset.url.path)", options: .mappedIfSafe)
                            DispatchQueue.main.async {
                                self.sendAttach(data: media as Data, type: .video)
                            }
                        } catch {
                            print("error convert")
                        }
                    }
                }
            } else if selectedAsset.mediaType == .image {
                let requestImageOption = PHImageRequestOptions()
                requestImageOption.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
                PHImageManager.default().requestImage(for: selectedAsset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: requestImageOption) { (image:UIImage?, _) in
                    DispatchQueue.main.async {
                        self.sendAttach(data: (image?.pngData() ?? Data()) as Data, type: .image)

                    }
                }
            }
        }
    }
    
    func sendAttach(data: Data, type: MediaAttchmentType){
        spinner.startAnimating()
        firstly{
            StoriesModel.addStoryMedia(attachment: data, type: type)
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                
                if type == .video {
                    self?.videoId = data.data?.id
                } else {
                    self?.galleryId.append(data.data?.id ?? 0)
                }
                var counter = self?.galleryId.count ?? 0
                //check count
                if self?.videoId != nil {
                    counter += 1
                }
                
                if counter == self?.selectedAssets.count {
                    self?.createStory()
                }
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
    
    
    //MARK: CREATE STORY
    func createStory() {
        spinner.startAnimating()
        firstly{
            StoriesModel.createStory(hashtags: hashtags, text: textTV.text ?? "", video: videoId, gallery: galleryId, isPrivate: false)
        }.done { [weak self] data in
            // if ok
            if (data.message!.lowercased() == "ok") {
                self?.spinner.stopAnimating()

                
                self?.view.makeToast("История успешно добавлена", point: .init(x: (self?.view.bounds.width)! / 2, y: (self?.view.bounds.height)! - 120), title: .none, image: .none) { _ in
                    self?.navigationController?.popViewController(animated: true)
                }
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
    
    
    
    //MARK: ZL PHOTO
    @IBAction func previewSelectPhoto(_ sender: UIButton) {
//        showImagePicker(true)
        var config = YPImagePickerConfiguration()
        config.library.maxNumberOfItems = 10
        config.library.onlySquare = false
        config.library.isSquareByDefault = true
        config.screens = [.library, .photo]
        config.showsCropGridOverlay = true
        config.showsCrop = .rectangle(ratio: (1/1))
        config.startOnScreen = .library
        config.library.mediaType = .photoAndVideo
        config.targetImageSize = YPImageSize.cappedTo(size: 1000)
        config.bottomMenuItemSelectedTextColour = UIColor(named: "AccentColor")!
//        config.targetImageSize = YPImageSize.
        let picker = YPImagePicker(configuration: config)
        
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            for item in items {
                switch item {
                case .photo(let photo):
                    self.save(image: photo.image, videoUrl: nil)
                case .video(let video):
                    self.save(image: nil, videoUrl: video.url)
                }
            }
            self.collectionView.reloadData()
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @objc func librarySelectPhoto() {
        showImagePicker(false)
    }
    
    func showImagePicker(_ preview: Bool) {
        
        // Custom UI
        ZLPhotoUIConfiguration.default()
            .navBarColor(UIColor(named: "VioletText")!)
            .navViewBlurEffectOfAlbumList(nil)
            .indexLabelBgColor(UIColor(named: "AccentColor")!)
            .indexLabelTextColor(.white)
        
        
        let editImageConfiguration = ZLPhotoConfiguration.default().editImageConfiguration
        editImageConfiguration
            .imageStickerContainerView(ImageStickerContainerView())
            .tools([.draw, .filter, .adjust, .mosaic])
            .adjustTools([.brightness, .contrast, .saturation])
            .clipRatios([ .wh1x1])
            .imageStickerContainerView(ImageStickerContainerView())
        
        ZLPhotoConfiguration.default()
            .editImageConfiguration(editImageConfiguration)
            .canSelectAsset { asset in
                return true
            }
            .noAuthorityCallback { type in
                switch type {
                case .library:
                    debugPrint("No library authority")
                case .camera:
                    debugPrint("No camera authority")
                case .microphone:
                    debugPrint("No microphone authority")
                }
            }
        
        let ac = ZLPhotoPreviewSheet(selectedAssets: true ? selectedAssets : [])
        ac.selectImageBlock = { [weak self] (images, assets, isOriginal) in
            self?.selectedImages = images
            self?.selectedAssets = assets
            self?.isOriginal = isOriginal
            self?.collectionView.reloadData()
            debugPrint("\(images)   \(assets)   \(isOriginal)")
        }
        ac.cancelBlock = {
            debugPrint("cancel select")
        }
        ac.selectImageRequestErrorBlock = { (errorAssets, errorIndexs) in
            debugPrint("fetch error assets: \(errorAssets), error indexs: \(errorIndexs)")
        }
        
        if preview {
            ac.showPreview(animate: true, sender: self)
        } else {
            ac.showPhotoLibrary(sender: self)
        }
    }
    
    //MARK: SAVE CHANGED PHOTO
    func save(image: UIImage?, videoUrl: URL?) {
        let hud = ZLProgressHUD(style: ZLPhotoUIConfiguration.default().hudStyle)
        if let image = image {
            hud.show()
            ZLPhotoManager.saveImageToAlbum(image: image) { [weak self] (suc, asset) in
                if suc, let at = asset {
                    self?.selectedImages.append(image)
                    self?.selectedAssets.append(at)
                    self?.collectionView.reloadData()
                } else {
                    debugPrint("error save photo")
                }
                hud.hide()
            }
        } else if let videoUrl = videoUrl {
            hud.show()
            ZLPhotoManager.saveVideoToAlbum(url: videoUrl) { [weak self] (suc, asset) in
                if suc, let at = asset {
                    self?.fetchImage(for: at)
                } else {
                    debugPrint("error save video")
                }
                hud.hide()
            }
        }
    }
    //MARK: GET IMAGE
    func fetchImage(for asset: PHAsset) {
        let option = PHImageRequestOptions()
        option.resizeMode = .fast
        option.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: option) { (image, info) in
            var downloadFinished = false
            if let info = info {
                downloadFinished = !(info[PHImageCancelledKey] as? Bool ?? false) && (info[PHImageErrorKey] == nil)
            }
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            if downloadFinished, !isDegraded {
                self.selectedImages = [image!]
                self.selectedAssets = [asset]
                self.collectionView.reloadData()
            }
        }
    }
}





//MARK: COLLECTION
extension CreateStoryController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var columnCount: CGFloat = (UI_USER_INTERFACE_IDIOM() == .pad) ? 6 : 4
        if UIApplication.shared.statusBarOrientation.isLandscape {
            columnCount += 10
        }
        let totalW = collectionView.bounds.width - (columnCount - 1) * 2
        let singleW = totalW / columnCount
        return CGSize(width: singleW, height: singleW)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! StoryImageCollectionViewCell
        
        cell.imageView.image = selectedImages[indexPath.row]
        cell.imageView.addSmallRadius()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ac = ZLPhotoPreviewSheet()
        ac.selectImageBlock = { [weak self] (images, assets, isOriginal) in
            self?.selectedImages = images
            self?.selectedAssets = assets
            self?.isOriginal = isOriginal
            self?.collectionView.reloadData()
            debugPrint("\(images)   \(assets)   \(isOriginal)")
            
        }
        
        ac.previewAssets(sender: self, assets: selectedAssets, index: indexPath.row, isOriginal: false, showBottomViewAndSelectBtn: true)
    }
    
}
