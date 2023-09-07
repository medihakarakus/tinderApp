//
//  MessageCell.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 16.05.23.
//

import LBTATools

class MessageCell: LBTAListCell<Message> {
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 20)
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        return tv
    }()
    
    let bubbleContainer = UIView(backgroundColor: #colorLiteral(red: 0.9019607902, green: 0.9019607902, blue: 0.9019607902, alpha: 1))
    
    override var item: Message! {
        didSet {
            textView.text = item.text
            
            if item.isFromCurrentLoggedUser {
                // right edge
                anchoredConstraints.trailing?.isActive = true
                anchoredConstraints.leading?.isActive = false
                bubbleContainer.backgroundColor = #colorLiteral(red: 0.0861729607, green: 0.7602494955, blue: 0.998857677, alpha: 1)
                textView.textColor = .white
            } else {
                // left edge
                anchoredConstraints.trailing?.isActive = false
                anchoredConstraints.leading?.isActive = true
                bubbleContainer.backgroundColor = #colorLiteral(red: 0.8971538544, green: 0.902125299, blue: 0.8977300525, alpha: 1)
                textView.textColor = .black
            }
        }
    }
    
    var anchoredConstraints: AnchoredConstraints!
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 12
        anchoredConstraints = bubbleContainer.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        anchoredConstraints.trailing?.isActive = false
        anchoredConstraints.leading?.constant = 20
        anchoredConstraints.trailing?.constant = -20
        
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        bubbleContainer.addSubview(textView)
        textView.fillSuperview(padding: .init(top: 4, left: 12, bottom: 4, right: 12))
    }
}

