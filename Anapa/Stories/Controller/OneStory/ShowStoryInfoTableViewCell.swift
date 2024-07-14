//
//  StoryInfoTableViewCell.swift
//  NotAlone
//
//  Created by Сергей Майбродский on 01.07.2022.
//

import UIKit

class ShowStoryInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userInfoStack: UIStackView!
    @IBOutlet weak var avatar: UIButton!
    @IBOutlet weak var name: UIButton!
    @IBOutlet weak var profiImage: UIImageView!
    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var hashtags: UILabel!
    @IBOutlet weak var hashtagsView: UIView!
    @IBOutlet weak var storyText: UILabel!
    @IBOutlet weak var storyView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var commentsCount: UILabel!
    @IBOutlet weak var viewCount: UILabel!
    @IBOutlet weak var hugButton: UIButton!
    @IBOutlet weak var hugCount: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.setOval()
        avatar.layer.borderWidth = 1
        avatar.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        dateView.layer.cornerRadius = 5
        dateView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        subscribeButton.addSmallRadius()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
