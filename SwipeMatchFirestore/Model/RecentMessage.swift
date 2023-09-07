//
//  RecentMessage.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 17.05.23.
//

import Firebase

struct RecentMessage {
    let text, uid, name, profileImageUrl: String
    let timestamp: Timestamp
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.timestamp = dictionary["timeStamp"] as? Timestamp ?? Timestamp(date: Date())
        
    }
}
