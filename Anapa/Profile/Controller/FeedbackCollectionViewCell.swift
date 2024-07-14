//
//  CommentCollectionViewCell.swift
//  Anapa
//
//  Created by Сергей Майбродский on 21.02.2023.
//

import UIKit
import Cosmos

class FeedbackCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var raiting: CosmosView!
}
