//
//  Message.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 16.05.23.
//

import Firebase

struct Message {
    let text, fromId, toId: String
    let timeStamp: Timestamp
    let isFromCurrentLoggedUser: Bool
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.fromId = dictionary["fromId"] as? String ?? ""
        self.toId = dictionary["toId"] as? String ?? ""
        self.timeStamp = dictionary["timeStamp"] as? Timestamp ?? Timestamp(date: Date())
        self.isFromCurrentLoggedUser = Auth.auth().currentUser?.uid == self.fromId
    }
}

