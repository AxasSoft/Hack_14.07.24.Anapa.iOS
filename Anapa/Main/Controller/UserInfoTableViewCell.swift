//
//  SearchUserTableViewCell.swift
//  Anapa
//
//  Created by Сергей Майбродский on 20.06.2023.
//

import UIKit

class UserInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var lastVisit: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.setOval()
    }
}
