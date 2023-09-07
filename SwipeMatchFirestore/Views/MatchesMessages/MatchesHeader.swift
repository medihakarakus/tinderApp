//
//  MatchesHeader.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 17.05.23.
//

import LBTATools

class MatchesHeader: UICollectionReusableView {
    let newMatchesLabel = UILabel(text: "New Matches", font: .boldSystemFont(ofSize: 18), textColor: #colorLiteral(red: 0.9986861348, green: 0.3591807783, blue: 0.3561093211, alpha: 1))
    let matchesHorizontalController = MatchesHorizontalController()
    let messagesLabel = UILabel(text: "Messages", font: .boldSystemFont(ofSize: 18), textColor: #colorLiteral(red: 0.9986861348, green: 0.3591807783, blue: 0.3561093211, alpha: 1))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stack(stack(newMatchesLabel).padLeft(20),
              matchesHorizontalController.view,
              stack(messagesLabel).padLeft(20), spacing: 20
        ).withMargins(.init(top: 20, left: 0, bottom: 8, right: 0))
     
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
