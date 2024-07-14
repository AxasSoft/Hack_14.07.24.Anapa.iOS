//
//  ProfileCommentTableViewCell.swift
//  Anapa
//
//  Created by Сергей Майбродский on 21.02.2023.
//

import UIKit
import SDWebImage
import CenteredCollectionView
import Cosmos

class ProfileCommentTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var commentHint: UILabel!
    @IBOutlet weak var feedbackCollection: UICollectionView!
    var feedbacks: [Feedback?] = []

    var currentCenteredPage = 0
    let cellPercentWidth: CGFloat = 1
    var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.addRadius()
        
        self.feedbackCollection.delegate = self
        self.feedbackCollection.dataSource = self
        
        centeredCollectionViewFlowLayout = (feedbackCollection.collectionViewLayout as! CenteredCollectionViewFlowLayout)  // Modify the collectionView's decelerationRate (REQUIRED STEP)
        feedbackCollection.decelerationRate = UIScrollView.DecelerationRate.fast  // Assign delegate and data source
        feedbackCollection.delegate = self
        feedbackCollection.dataSource = self
        
        let screenSize: CGRect = UIScreen.main.bounds
        // Configure the required item size (REQUIRED STEP)
        
        centeredCollectionViewFlowLayout.itemSize = CGSize( width: screenSize.size.width - 40,  height: 160 )  // Configure the optional inter item spacing (OPTIONAL STEP)
        centeredCollectionViewFlowLayout.minimumLineSpacing = 20
        
        // Get rid of scrolling indicators
        feedbackCollection.showsVerticalScrollIndicator = false
        feedbackCollection.showsHorizontalScrollIndicator = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedbacks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedbackCell = collectionView.dequeueReusableCell(withReuseIdentifier: "feedbackCell", for: indexPath) as! FeedbackCollectionViewCell
        feedbackCell.comment.text = feedbacks[indexPath.item]?.text
        feedbackCell.name.text = (feedbacks[indexPath.item]?.user?.firstName ?? "") + " " + (feedbacks[indexPath.item]?.user?.lastName ?? "")
        feedbackCell.raiting.rating = Double(feedbacks[indexPath.item]?.rate ?? 0)
        feedbackCell.date.text = feedbacks[indexPath.item]?.created?.toDay
        feedbackCell.backView.addRadius()
        feedbackCell.backView.layer.borderWidth = 1
        feedbackCell.backView.layer.borderColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.12).cgColor
        return feedbackCell
    }
}
