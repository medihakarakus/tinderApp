//
//  ViewController.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 24.04.23.
//

import UIKit
import FirebaseFirestore
import JGProgressHUD
import Firebase

class HomeController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate, CardViewDelegate {
    
  let bottomControls = HomeBottomControlStackView()
    let cardsDeckView = UIView()
    let topStackView = TopNavigationStackView()
    
    var cardViewModels = [CardViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        topStackView.messageButton.addTarget(self, action: #selector(handleMessages), for: .touchUpInside)
        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        bottomControls.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomControls.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        
        setupLayout()
        fetchCurrentUser()
    }
    
    @objc func handleMessages() {
        let vc = MatchesMessagesController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            let registrationController = RegistrationController()
            registrationController.delegate = self
            let navController = UINavigationController(rootViewController: registrationController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
    }
    
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
    
    fileprivate var user: User?
    
    fileprivate func fetchCurrentUser() {
        hud.textLabel.text = "loading"
        hud.show(in: view)
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, err in
            self.hud.dismiss()
            if let err = err {
                print(err)
                return
            }
            
            guard let dictionary = snapshot?.data() else { return }
            self.user = User(dictionary: dictionary)
            self.fetchSwipes()
        }
    }
    
    var swipes = [String: Int]()
    func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("swipes").document(uid).getDocument { snapshot, err in
            self.hud.dismiss()
            if let err = err {
                print("Failed to fetch swipes info for currently logged in user: ", err)
                return
            }
//            guard let data = snapshot?.data() as? [String: Int] else { return }
            self.swipes = snapshot?.data() as? [String: Int] ?? [:]
            self.fetchUsersFromFirestore()
        }
    }
    
    var lastFetchedUser: User?
    let hud = JGProgressHUD(style: .dark)
    
    fileprivate func fetchUsersFromFirestore() {
        
        let minAge = user?.minSeekingAge ?? SettingsController.defaultMinSeekingAge
        let maxAge = user?.maxSeekingAge ?? SettingsController.defaultMaxSeekingAge
        
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge).limit(to: 10)
        topCardView = nil
        query.getDocuments { snapshot, err in
            self.hud.dismiss(animated: true)
            if let err = err {
                print("Failed to fetch users: ", err)
                return
            }
            
            // linked list
            var previousCardView: CardView?
            snapshot?.documents.forEach({ documentSnapshot in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                self.users[user.uid ?? ""] = user
                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
//                let hasNotSwipedBefore = self.swipes[user.uid!] == nil
                let hasNotSwipedBefore = true
                if isNotCurrentUser && hasNotSwipedBefore {
                    let cardView = self.setupCardFromUser(user: user)
                    
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
            })
        }
    }
    
    var users = [String: User]()
    
    var topCardView: CardView?
    @objc func handleLike() {
        saveSwipeToFirestore(didLike: 1)
        performSwipeAnimation(translation: 700, angle: 15)
    }
    
    @objc func handleDislike() {
        saveSwipeToFirestore(didLike: 0)
        performSwipeAnimation(translation: -700, angle: -15)
    }
    
    
    func saveSwipeToFirestore(didLike: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let cardUID = topCardView?.cardViewModel.uid else { return }
        
        let documentData = [cardUID: didLike]
       
        Firestore.firestore().collection("swipes").document(uid).getDocument(completion: { snapshot, err in
            if let err = err {
                print("Failed to fetch swipe document: ", err)
                return
            }
            
            if snapshot?.exists == true {
                Firestore.firestore().collection("swipes").document(uid).updateData(documentData) { err in
                    if let err = err {
                        print("Failed to update swipe data: ", err)
                        return
                    }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            } else {
                Firestore.firestore().collection("swipes").document(uid).setData(documentData) { err in
                    if let err = err {
                        print("Failed to save swipe data: ", err)
                        return
                    }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            }
        })
    }
    
    func checkIfMatchExists(cardUID: String) {
        Firestore.firestore().collection("swipes").document(cardUID).getDocument(completion: { snapshot, err in
            if let err = err {
                print("Failed to fetch swipe document: ", err)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let hasMatched = data[uid] as? Int == 1
            
            if hasMatched {
                self.presentMatchView(cardUID: cardUID)
                
                guard let cardUser = self.users[cardUID] else { return }
                let data = ["name": cardUser.name ?? "", "profileImageUrl": cardUser.imageUrl1 ?? "", "uid": cardUID, "timestamp": Timestamp(date: Date())]
                Firestore.firestore().collection("matches_messages").document(uid).collection("matches").document(cardUID).setData(data) { err in
                    if let err = err {
                        print("Failed to save swipe data: ", err)
                        return
                    }
                }
                
                guard let currentUser = self.user else { return }
                let otherMatchdata = ["name": currentUser.name ?? "", "profileImageUrl": currentUser.imageUrl1 ?? "", "uid": currentUser.uid ?? "", "timestamp": Timestamp(date: Date())]
                Firestore.firestore().collection("matches_messages").document(cardUID).collection("matches").document(uid).setData(otherMatchdata) { err in
                    if let err = err {
                        print("Failed to save swipe data: ", err)
                        return
                    }
                }
            }
        })
    }
    
    func presentMatchView(cardUID: String) {
        let matchView = MatchView()
        matchView.cardUID = cardUID
        matchView.currentUser = self.user
        view.addSubview(matchView)
        matchView.fillSuperview()
    }
    
    fileprivate func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.5
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        CATransaction.commit()
    }
    
    func didRemoveCard(cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
    }
    
    fileprivate func setupCardFromUser(user: User) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        return cardView
    }
    
   
    func didTapMoreInfo(cardViewModel: CardViewModel) {
        let userDetailsController = UserDetailsController()
        userDetailsController.cardViewModel = cardViewModel
        let nc = UINavigationController(rootViewController: userDetailsController)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true)
    }
    
    @objc func handleSettings() {
        let settingsController = SettingsController()
        settingsController.delegate = self
        let nc = UINavigationController(rootViewController: settingsController)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true)
    }
    
    func didSaveSettings() {
        fetchCurrentUser()
    }
    
    @objc fileprivate func handleRefresh() {
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
        fetchUsersFromFirestore()
    }
    
    fileprivate func setupFirestoreUserCards() {
        cardViewModels.forEach { cardVM in
            let cardView = CardView(frame: .zero)
            cardView.cardViewModel = cardVM
            
            cardsDeckView.addSubview(cardView)
            cardView.anchor(top: cardsDeckView.topAnchor, leading: cardsDeckView.leadingAnchor, bottom: cardsDeckView.bottomAnchor, trailing: cardsDeckView.trailingAnchor)
        }
    }
    
    //MARK:- Fileprivate
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomControls])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        overallStackView.bringSubviewToFront(cardsDeckView)
    }
    
}

