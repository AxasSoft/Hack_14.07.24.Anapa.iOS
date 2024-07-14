//
//  ProfileTableViewCell.swift
//  Anapa
//
//  Created by Сергей Майбродский on 22.01.2023.
//

import UIKit
import SDWebImage

class ProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var backViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var isOnline: UIView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var trustImage: UIImageView!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var aboutUserStack: UIStackView!
    @IBOutlet weak var aboutUser: UILabel!
    @IBOutlet weak var site: UIButton!
    
    @IBOutlet weak var subscriptionsView: UIView!
    @IBOutlet weak var subscriptionsLabel: UILabel!
    @IBOutlet weak var postsCountView: UIView!
    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var subscribersView: UIView!
    @IBOutlet weak var subscribersLabel: UILabel!
    
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingCount: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.addRadius()
        avatar.setOval()
        avatar.smallWhiteBorder()
        isOnline.setOval()
        isOnline.smallWhiteBorder()
        
        actionButton.addSmallRadius()
        
        subscriptionsView.addRadius()
        subscribersView.addRadius()
        postsCountView.addRadius()
        ratingView.addRadius()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(profile: Profile?, myProfile: Profile) {
        if profile?.isBusiness == true || (profile?.id ?? 0) == 3 {
            backViewTopConstraint.constant = 120
        } else {
            backViewTopConstraint.constant = 50
        }
        avatar.sd_imageIndicator = SDWebImageActivityIndicator.gray
        avatar.sd_setImage(with: URL(string: profile?.avatar ?? ""), placeholderImage: UIImage(named: "Avatar"), options: [], context: [:])
        name.text = (profile?.firstName ?? "") + " " + (profile?.lastName ?? "")
        if profile?.inWhitelist == true {
            trustImage.image = UIImage(named: "UserWhiteList")
            trustImage.isHidden = false
        } else if profile?.inBlacklist == true {
            trustImage.image = UIImage(named: "UserBlackList")
            trustImage.isHidden = false
        } else {
            trustImage.isHidden = true
        }
        
        
        if profile?.isOnline == true {
            isOnline.isHidden = false
        } else {
            isOnline.isHidden = true
        }
        
        if profile?.isBusiness == true {
            if profile?.companyInfo == "" || profile?.companyInfo == nil {
                aboutUserStack.isHidden = true
            } else {
                aboutUserStack.isHidden = false
                aboutUser.text = profile?.companyInfo ?? ""
            }
        } else {
            if profile?.experience == "" || profile?.experience == nil {
                aboutUserStack.isHidden = true
            } else {
                aboutUserStack.isHidden = false
                aboutUser.text = profile?.experience ?? ""
            }
        }
        
        if profile?.site == "" || profile?.site == nil {
            site.isHidden = true
        } else {
            site.isHidden = false
            site.setTitle(profile?.site, for: .normal)
        }
        
        if (profile?.id ?? 0) != myProfile.id {
            if profile?.inSubscriptions == true {
                actionButton.setTitle("Отписаться", for: .normal)
            } else {
                actionButton.setTitle("Подписаться", for: .normal)
            }
        }
        
        if profile?.status != "" && profile?.status != nil {
            status.text = profile?.status
            status.isHidden = false
        } else {
            status.isHidden = true
        }

        postsCountLabel.text = "\(profile?.storiesCount ?? 0)"
        subscriptionsLabel.text = "\(profile?.subscriptionsCount ?? 0)"
        subscribersLabel.text = "\(profile?.subscribersCount ?? 0)"
        
    }
}
