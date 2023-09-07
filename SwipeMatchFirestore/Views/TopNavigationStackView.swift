//
//  TopNavigationStackView.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 24.04.23.
//

import UIKit

class TopNavigationStackView: UIStackView {
    
    let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "top_left_profile")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "top_right_messages")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let fireImageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "app_icon")?.withRenderingMode(.alwaysOriginal))
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        distribution = .equalCentering
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
        
        let subViews = [settingsButton, fireImageView, messageButton ]
        
        subViews.forEach { (view) in
            addArrangedSubview(view)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
