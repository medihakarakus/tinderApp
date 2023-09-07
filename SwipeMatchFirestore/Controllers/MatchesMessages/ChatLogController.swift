//
//  ChatLogController.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 15.05.23.
//

import LBTATools
import Firebase

class ChatLogController: LBTAListController<MessageCell, Message>, UICollectionViewDelegateFlowLayout {
    deinit {
        print("hello")
    }
    fileprivate lazy var customNavBar = MessagesNavBar(match: match)
    fileprivate let navBarHeight: CGFloat = 150
    fileprivate let match: Match
    
    init(match: Match) {
        self.match = match
        super.init()
    }
    
    lazy var customInputView: CustomInputAccessoryView = {
        let civ = CustomInputAccessoryView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 50))
        civ.sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return civ
    }()

    @objc fileprivate func handleSend() {
        saveToFromMessages()
        saveToFromRecentMessages()
    }
    
    func saveToFromRecentMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let data = ["text": customInputView.textView.text ?? "", "name": match.name, "profileImageUrl": match.profileImageUrl, "timestamp": Timestamp(date: Date()), "uid": match.uid] as [String : Any]
        
        Firestore.firestore().collection("matches_messages").document(currentUserId).collection("recent_messages").document(match.uid).setData(data) { err in
            if let err = err {
                print("Failed to save recent message:", err)
                return
            }
        }
        
        guard let currentUser = self.currentUser else { return }
        
        let toData = ["text": customInputView.textView.text ?? "", "name": currentUser.name ?? "" , "profileImageUrl": currentUser.imageUrl1 ?? "", "timestamp": Timestamp(date: Date()), "uid": currentUserId] as [String : Any]
        
        Firestore.firestore().collection("matches_messages").document(match.uid).collection("recent_messages").document(currentUserId).setData(toData) { err in
            if let err = err {
                print("Failed to save recent message:", err)
                return
            }
        }
    }
    
    func saveToFromMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let collection = Firestore.firestore().collection("matches_messages").document(currentUserId).collection(match.uid)
        
        let data = ["text": customInputView.textView.text ?? "", "fromId": currentUserId, "toId": match.uid, "timestamp": Timestamp(date: Date())] as [String : Any]
        
        collection.addDocument(data: data) { (err) in
            if let err = err {
                print("Failed to save message:", err)
                return
            }
            
            print("Successfully saved msg into Firestore")
            self.customInputView.textView.text = nil
            self.customInputView.placeholderLabel.isHidden = false
        }
        
        let toCollection = Firestore.firestore().collection("matches_messages").document(match.uid).collection(currentUserId)
        
        toCollection.addDocument(data: data) { (err) in
            if let err = err {
                print("Failed to save message:", err)
                return
            }
            
            self.customInputView.textView.text = nil
            self.customInputView.placeholderLabel.isHidden = false
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return customInputView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentUser()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        collectionView.keyboardDismissMode = .interactive
        collectionView.alwaysBounceVertical = true
        
        fetchMessages()
        setupUI()
    }
    fileprivate var currentUser: User?
    
    fileprivate func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, err in
            if let err = err {
                print(err)
                return
            }
            guard let dictionary = snapshot?.data() else { return }
            self.currentUser = User(dictionary: dictionary)
        }
    }
    
    @objc func handleKeyboardShow() {
        self.collectionView.scrollToItem(at: [0, items.count - 1], at: .bottom, animated: true)
    }
    
    var listener: ListenerRegistration?
    fileprivate func fetchMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let query = Firestore.firestore().collection("matches_messages").document(currentUserId).collection(match.uid).order(by: "timestamp")
        listener = query.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Failed to fetch messages:", err)
                return
            }
            
            querySnapshot?.documentChanges.forEach({ (change) in
                if change.type == .added {
                    let dictionary = change.document.data()
                    self.items.append(.init(dictionary: dictionary))
                }
            })
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: [0, self.items.count - 1], at: .bottom, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            listener?.remove()
        }
    }
    
    fileprivate func setupUI() {
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: navBarHeight))
        
        collectionView.contentInset.top = navBarHeight
        collectionView.verticalScrollIndicatorInsets.top = navBarHeight
        
        let statusBarCover = UIView(backgroundColor: .white)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let estimatedSizeCell = MessageCell(frame: .init(x: 0, y: 0, width: width, height: 1000))
        estimatedSizeCell.item = self.items[indexPath.item]
        estimatedSizeCell.layoutIfNeeded()
        
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(.init(width: width, height: 1000))
        return .init(width: width , height: estimatedSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
