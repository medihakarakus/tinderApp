//
//  CardViewModel.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 25.04.23.
//

import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel 
}

class CardViewModel {
    let uid: String
    let imageNames: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    init(uid: String, imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.uid = uid
        self.imageNames = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
    
    fileprivate var imageIndex = 0 {
        didSet {
            let imageUrl = imageNames[imageIndex]
            imageIndexObserver?(imageIndex, imageUrl)
        }
    }
    
    // Reactive programming
    var imageIndexObserver: ((Int, String?) -> ())?
    
    func advanceToNextPhoto() {
        imageIndex = min(imageIndex + 1, imageNames.count - 1)
    }
    
    func goToPreviousPhoto() {
        imageIndex = max(0, imageIndex - 1)
    }
}
