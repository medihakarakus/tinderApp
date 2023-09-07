//
//  MessagesNavBar.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 15.05.23.
//

import LBTATools

class MessagesNavBar: UIView {
    let userProfileImageView = CircularImageView(width: 80, image: #imageLiteral(resourceName: "kelly1"))
    let userNameLabel = UILabel(text: "User Name", font: .systemFont(ofSize: 16, weight: .semibold), textColor: .darkGray)
    let backButton = UIButton(image: #imageLiteral(resourceName: "back"), tintColor: #colorLiteral(red: 0.9986861348, green: 0.3591807783, blue: 0.3561093211, alpha: 1))
    let flagButton = UIButton(image: #imageLiteral(resourceName: "flag"), tintColor: #colorLiteral(red: 0.9986861348, green: 0.3591807783, blue: 0.3561093211, alpha: 1))
    fileprivate let match: Match
    
    init(match: Match) {
        self.match = match
        super.init(frame: .zero)
        
        userNameLabel.text = match.name
        userProfileImageView.sd_setImage(with: URL(string: match.profileImageUrl))
        
        backgroundColor = .white
        setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        
        let middleStack = hstack(
            stack(
                userProfileImageView,
                userNameLabel,
                spacing: 8,
                alignment: .center),
            alignment: .center
        )
        
        hstack(backButton.withWidth(50),
               middleStack,
               flagButton).withMargins(.init(top: 0, left: 4, bottom: 0, right: 16))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
