//
//  TopInfoCollectionViewCell.swift
//  Anapa
//
//  Created by Сергей Майбродский on 13.08.2023.
//

import UIKit

class MainEventCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var ageView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.addRadius()
        cover.addRadius()
        nameView.addRadius()
        dateView.addRadius()
        ageView.addRadius()
        self.addRadius()
    }
}
