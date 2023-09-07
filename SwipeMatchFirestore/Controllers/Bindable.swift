//
//  Bindable.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 27.04.23.
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    
    var observer: ((T?)->())?
    
    func bind(observer: @escaping (T?) ->()) {
        self.observer = observer
    }
    
}
