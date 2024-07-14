//
//  MainSaleCollectionViewCell.swift
//  Anapa
//
//  Created by Сергей Майбродский on 29.09.2023.
//

import UIKit

class MainSaleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var isFavoriteDidTapClosure: (() -> Void)!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addRadius()
        favoriteButton.setOval()
    }
    
    
    
    @IBAction func isFavoriteButtonDidTapped(_ sender: UIButton) {
        isFavoriteDidTapClosure()
    }
}
