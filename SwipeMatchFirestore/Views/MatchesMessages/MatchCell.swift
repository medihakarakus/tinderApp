//
//  MatchCell.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 16.05.23.
//

import LBTATools

class MatchCell: LBTAListCell<Match> {
    
    let profileImageView = UIImageView(image: #imageLiteral(resourceName: "kelly1"), contentMode: .scaleAspectFill)
    let usernameLabel = UILabel(text: "User Name", font: .systemFont(ofSize: 14, weight: .semibold), textColor: .darkGray, textAlignment: .center, numberOfLines: 2)
    
    override var item: Match! {
        didSet {
            usernameLabel.text = item.name
            profileImageView.sd_setImage(with: URL(string: item.profileImageUrl))
        }
    }

    override func setupViews() {
        super.setupViews()
        
        profileImageView.clipsToBounds = true
        profileImageView.constrainHeight(80)
        profileImageView.constrainWidth(80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        stack(stack(profileImageView, alignment: .center), usernameLabel)
        
    }
}
