//
//  ProfileCell.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 12/4/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileCell: UITableViewCell {

    @IBOutlet var profileImageView : UIImageView!
    @IBOutlet var profileBackView : UIView!
    @IBOutlet var backView: UIView!
    @IBOutlet var lowerView: UIView!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var topicsButton: UIButton!
    @IBOutlet var nameLabel : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func download_image(image_url: String){
        // KingFisher download
        let url = URL(string: image_url)
//        let image = UIImage(named: "default_profile_icon")
        profileImageView.kf.setImage(with: url)//, placeholder: image)
    }

}
