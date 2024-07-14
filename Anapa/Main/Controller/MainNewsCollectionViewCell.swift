//
//  MainNewsCollectionViewCell.swift
//  Anapa
//
//  Created by Сергей Майбродский on 21.07.2023.
//

import UIKit

class MainNewsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var body: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addRadius()
    }
}
