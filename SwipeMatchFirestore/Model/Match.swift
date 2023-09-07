//
//  Match.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 16.05.23.
//

import Foundation

struct Match {
    let name, profileImageUrl, uid: String
    
    init(dictionary: [String:Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
