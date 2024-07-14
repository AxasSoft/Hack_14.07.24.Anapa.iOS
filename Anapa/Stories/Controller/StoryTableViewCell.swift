//
//  StoryTableViewCell.swift
//  NotAlone
//
//  Created by Сергей Майбродский on 29.06.2022.
//

import UIKit
import SDWebImage
import CenteredCollectionView
import SwiftVideoBackground
import SwiftyMarkdown
import Toast_Swift

protocol StoryTableViewCellDelegate: AnyObject {
    func getImageURL(imageUrl: String?)
}

class StoryTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var collectionViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var userInfoStack: UIStackView!
    @IBOutlet weak var avatar: UIButton!
    @IBOutlet weak var name: UIButton!
    @IBOutlet weak var hashStack: UIStackView!
    @IBOutlet weak var axasHashtags: AxasHashtagTextView!
    @IBOutlet weak var storyText: UITextView!
    @IBOutlet weak var readMoreButton: UIButton!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var mediaCollecctionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var hugButton: UIButton!
    @IBOutlet weak var hugCount: UILabel!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var muteButton: UIButton!
    
    var story: Story?
    weak var delegate: StoryTableViewCellDelegate?
    
    var currentCenteredPage = 0
    let cellPercentWidth: CGFloat = 1
    var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.addRadius()
        avatar.setOval()
        avatar.layer.borderWidth = 1
        avatar.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        avatar.contentMode = .scaleAspectFill
        self.mediaCollecctionView.delegate = self
        self.mediaCollecctionView.dataSource = self
        
        
        centeredCollectionViewFlowLayout = (mediaCollecctionView.collectionViewLayout as! CenteredCollectionViewFlowLayout)  // Modify the collectionView's decelerationRate (REQUIRED STEP)
        mediaCollecctionView.decelerationRate = UIScrollView.DecelerationRate.fast  // Assign delegate and data source
        mediaCollecctionView.delegate = self
        mediaCollecctionView.dataSource = self
        
        let screenSize: CGRect = UIScreen.main.bounds
        // Configure the required item size (REQUIRED STEP)
        
        centeredCollectionViewFlowLayout.itemSize = CGSize( width: screenSize.size.width + 22,  height: screenSize.size.width + 22 )  // Configure the optional inter item spacing (OPTIONAL STEP)
        centeredCollectionViewFlowLayout.minimumLineSpacing = 1
        
        // Get rid of scrolling indicators
        mediaCollecctionView.showsVerticalScrollIndicator = false
        mediaCollecctionView.showsHorizontalScrollIndicator = false
        
        
        
        muteButton.isHidden = true
        muteButton.setOval()
        
    }
    

    
    func reloadCollectionView() -> Void {
        self.mediaCollecctionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = story?.gallery.count ?? 0
        pageControl.isHidden = !((story?.gallery.count ?? 0) > 1)
        var videoCount = 0
        if story?.video?.mainLink != nil {
            videoCount += 1
            pageControl.numberOfPages = (story?.gallery.count ?? 0) + 1
        }
        return ( story?.gallery.count ?? 0 ) + videoCount
    }
    
    let videoBackground = VideoBackground()
    //MARK: VIDEO BACKGROUND
    var isPlaying = false
    @objc func playVideo(_ sender: Any){
        isPlaying = !isPlaying
        mediaCollecctionView.reloadData()
    }
    var isMuted = true
    @IBAction func muteVideo(_ sender: UIButton){
        isMuted = !isMuted
        videoBackground.isMuted = isMuted
        if isMuted {
            muteButton.setImage(UIImage(systemName: "speaker.slash.circle.fill"), for: .normal)
        } else {
            muteButton.setImage(UIImage(systemName: "speaker.circle.fill"), for: .normal)
        }
    }
    
    
    //MARK: COLLECTION
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! StoryImageCollectionViewCell
        
        cell.videoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playVideo)))
        cell.playButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        
        if story?.video?.mainLink != nil && indexPath.row == 0 {
            cell.imageView?.isHidden = true
            cell.videoView.isHidden = false
            if isPlaying {
                cell.playButton.isHidden = true
                muteButton.isHidden = false
                videoBackground.play(view: cell.videoView, url: URL( string: story?.video?.mainLink ?? "")!, isMuted: isMuted, willLoopVideo: true)
                
                videoBackground.restart()
            } else {
                cell.playButton.isHidden = false
                muteButton.isHidden = true
                videoBackground.play(view: cell.videoView, url: URL( string: story?.video?.mainLink ?? "")!, isMuted: isMuted, willLoopVideo: false)
                
                videoBackground.pause()
            }
            
            return cell
        } else {
            cell.imageView?.isHidden = false
            cell.videoView.isHidden = true
            cell.playButton.isHidden = true
            muteButton.isHidden = true
        }
        if cell.imageView != nil && indexPath.row <= story?.gallery.count ?? 0{
            var index = indexPath.row
            if story?.video?.mainLink != nil {
                index -= 1
            }
            cell.imageView.sd_setImage(with: URL(string: story?.gallery[index]?.mainLink ?? ""), placeholderImage: UIImage(named: "Guest"))

            let longTap = CustomTapGestureRecognizer(target: self, action: #selector(sendURLToController))
            longTap.text = story?.gallery[index]?.mainLink
            cell.imageView?.addGestureRecognizer(longTap)
        }
        
        
        cell.imageView.contentMode = .scaleAspectFit
        
        return cell
    }
    
    
    @objc func sendURLToController(_ sender: CustomTapGestureRecognizer){
        delegate?.getImageURL(imageUrl: sender.text)
    }

    //MARK: PAGE CONTROL
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}


