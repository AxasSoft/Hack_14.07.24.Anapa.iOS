//
//  InfoCategoryCollectionViewCell.swift
//  Anapa
//
//  Created by Сергей Майбродский on 09.04.2023.
//

import UIKit

import UIKit

class InfoCategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var category: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.addRadius()
    }
}
