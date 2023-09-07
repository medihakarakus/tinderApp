//
//  RegistrationViewModel.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 27.04.23.
//

import UIKit
import Firebase
import FirebaseStorage

class RegistrationViewModel {
    var bindableIsRegistering = Bindable<Bool>()
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()

    var fullName: String? { didSet { checkFormValidity() } }
    var email: String? { didSet {checkFormValidity() } }
    var password: String? { didSet { checkFormValidity() } }
    

    func performRegistration(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        bindableIsRegistering.value = true
        Auth.auth().createUser(withEmail: email, password: password) { res, err in
            if let err = err {
                completion(err)
                return
            }
            print("Successfully registered user: ", res?.user.uid ?? "")

            self.saveImageToFirebase(completion: completion)
        }
    }

    fileprivate func saveImageToFirebase(completion: @escaping (Error?) -> ()) {
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)" )
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        ref.putData(imageData, metadata: nil) { _, err in
            if let err = err {
                completion(err)
                return
            }
            print("Finished uploading img to storage")
            ref.downloadURL { url, err in
                if let err = err {
                    completion(err)
                    return
                }
                self.bindableIsRegistering.value = false
                print("Download url of our image is:", url?.absoluteString ?? "")
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
            }
        }
    }

    func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) -> ()) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData: [String : Any] = ["fullName": fullName ?? "",
                       "uid": uid,
                       "imageUrl1": imageUrl,
                       "age": 18,
                       "minSeekingAge": SettingsController.defaultMinSeekingAge,
                       "maxSeekingAge": SettingsController.defaultMaxSeekingAge
        ]

        Firestore.firestore().collection("users").document(uid).setData(docData) { err in
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        }
    }
    
    func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false && bindableImage.value != nil
        bindableIsFormValid.value = isFormValid
    }


}

//
//  RegistrationViewModel.swift
//  SwipeMatchFirestoreLBTA
//
//  Created by Brian Voong on 11/14/18.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

//import UIKit
//import Firebase
//import FirebaseStorage
//
//class RegistrationViewModel {
//
//    var bindableIsRegistering = Bindable<Bool>()
//    var bindableImage = Bindable<UIImage>()
//    var bindableIsFormValid = Bindable<Bool>()
//
//    var fullName: String? {
//        didSet {
//            checkFormValidity()
//        }
//    }
//    var email: String? { didSet { checkFormValidity() } }
//    var password: String? { didSet { checkFormValidity() } }
//
//    func checkFormValidity() {
//        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false && bindableImage.value != nil
//        bindableIsFormValid.value = isFormValid
//    }
//
//    func performRegistration(completion: @escaping (Error?) -> ()) {
//        guard let email = email, let password = password else { return }
//        bindableIsRegistering.value = true
//        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
//            if let err = err {
//                completion(err)
//                return
//            }
//
//            print("Successfully registered user:", res?.user.uid ?? "")
//            self.saveImageToFirebase(completion: completion)
//        }
//    }
//
//    fileprivate func saveImageToFirebase(completion: @escaping (Error?) ->()) {
//        let filename = UUID().uuidString
//        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
//        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
//        ref.putData(imageData, metadata: nil, completion: { (_, err) in
//
//            if let err = err {
//                completion(err)
//                return // bail
//            }
//
//            print("Finished uploading image to storage")
//            ref.downloadURL(completion: { (url, err) in
//                if let err = err {
//                    completion(err)
//                    return
//                }
//
//                let imageUrl = url?.absoluteString ?? ""
//                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
//            })
//
//        })
//    }
//
//    fileprivate func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) -> ()) {
//        let uid = Auth.auth().currentUser?.uid ?? ""
//        let docData: [String : Any] = [
//            "fullName": fullName ?? "",
//            "uid": uid,
//            "imageUrl1": imageUrl,
//            "age": 18,
//            "minSeekingAge": SettingsController.defaultMinSeekingAge,
//            "maxSeekingAge": SettingsController.defaultMaxSeekingAge
//            ]
//        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
//            self.bindableIsRegistering.value = false
//            if let err = err {
//                completion(err)
//                return
//            }
//            completion(nil)
//        }
//    }
//}
//
