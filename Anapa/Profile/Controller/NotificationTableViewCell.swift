//
//  NotificationTableViewCell.swift
//  Anapa
//
//  Created by Сергей Майбродский on 21.02.2023.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var created: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var notifText: UILabel!
    @IBOutlet weak var reviewButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        reviewButton.addRadius()
        cover.setOval()
        backView.addRadius()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
