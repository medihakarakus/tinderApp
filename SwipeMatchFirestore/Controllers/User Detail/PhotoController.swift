//
//  PhotoController.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 06.05.23.
//

import UIKit

class PhotoController: UIViewController {
    let imageView = UIImageView(image: #imageLiteral(resourceName: "jane3") )
    
    init(imageUrl: String) {
        if let url = URL(string: imageUrl) {
            imageView.sd_setImage(with: url)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        imageView.fillSuperview()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

