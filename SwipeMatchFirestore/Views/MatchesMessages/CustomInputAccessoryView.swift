//
//  CustomInputAccessoryView.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 16.05.23.
//

import LBTATools

class CustomInputAccessoryView: UIView {
    let textView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        return textView
    }()
    
    let sendButton = UIButton(title: "Send", titleColor: .black, font: .boldSystemFont(ofSize: 14), target: nil, action: nil)
    
    let placeholderLabel = UILabel(text: "Enter Message", font: .systemFont(ofSize: 16), textColor: .lightGray)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupShadow(opacity: 0.1, radius: 8, offset: .init(width: 0, height: -8), color: .lightGray)
        autoresizingMask = .flexibleHeight
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextView.textDidChangeNotification, object: nil)
        
        sendButton.constrainHeight(60)
        sendButton.constrainWidth(60)
        
        hstack(textView,
                       sendButton.withSize(.init(width: 60, height: 60)),
                       alignment: .center
        ).withMargins(.init(top: 0, left: 16, bottom: 0, right: 16))
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: sendButton.leadingAnchor, padding: .init(top: 0, left: 20, bottom: 0, right: 0))
        placeholderLabel.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor).isActive = true
    }
    
    @objc func handleTextChange() {
        placeholderLabel.isHidden = textView.text.count != 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
