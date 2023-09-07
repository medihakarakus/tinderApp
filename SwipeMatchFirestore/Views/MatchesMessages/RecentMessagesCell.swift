//
//  RecentMessagesCell.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 17.05.23.
//

import LBTATools

class RecentMessagesCell: LBTAListCell<RecentMessage> {
    
    let userProfileImageView = UIImageView(image: #imageLiteral(resourceName: "jane3"), contentMode: .scaleAspectFill)
    let usernameLabel = UILabel(text: "username", font: .systemFont(ofSize: 18), numberOfLines: 2)
    let messageTextLabel = UILabel(text: "some longline of text that sholcnd user name   djkcx mediha karakus leyla", font: .systemFont(ofSize: 16), textColor: .gray, numberOfLines: 2)
    
    override var item: RecentMessage! {
        didSet {
            usernameLabel.text = item.name
            userProfileImageView.sd_setImage(with: URL(string: item.profileImageUrl))
            messageTextLabel.text = item.text
        }
    }
    
    override func setupViews() {
        userProfileImageView.layer.cornerRadius = 94 / 2
        hstack(userProfileImageView.withWidth(94).withHeight(94),
               stack(usernameLabel, messageTextLabel, spacing: 2),
               spacing: 20,
               alignment: .center
        ).padLeft(20).padRight(20)
        
        addSeparatorView(leadingAnchor: usernameLabel.leadingAnchor)
    }
}
