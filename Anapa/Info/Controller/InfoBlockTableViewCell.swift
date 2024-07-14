//
//  InfoBlockTableViewCell.swift
//  Anapa
//
//  Created by Сергей Майбродский on 23.01.2023.
//

import UIKit

class InfoBlockTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var body: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backView.addRadius()
    }
}
