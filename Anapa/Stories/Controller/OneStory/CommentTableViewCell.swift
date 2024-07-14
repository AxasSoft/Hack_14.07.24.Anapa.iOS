//
//  CommentTableViewCell.swift
//  NotAlone
//
//  Created by Сергей Майбродский on 14.07.2022.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIButton!
    @IBOutlet weak var name: UIButton!
    @IBOutlet weak var textComment: UILabel!
    @IBOutlet weak var date: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.setOval()
        avatar.layer.borderWidth = 1
        avatar.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        avatar.contentMode = .scaleAspectFill
    }
}
