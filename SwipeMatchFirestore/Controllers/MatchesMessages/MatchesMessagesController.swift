//
//  MatchesMessagesController.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 09.05.23.
//

import LBTATools
import Firebase

class MatchesMessagesController: LBTAListHeaderController<RecentMessagesCell, RecentMessage,MatchesHeader >, UICollectionViewDelegateFlowLayout {
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func setupHeader(_ header: MatchesHeader) {
        header.matchesHorizontalController.rootMatchesController = self
    }
    
    func didSelectMatchFromHeader(match: Match) {
        let chatLogController = ChatLogController(match: match)
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: 250)
    }
    
    let customNavBar = MatchesNavBar()
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 130)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRecentMessages()
        setupUI()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            listener?.remove()
        }
    }
    deinit {
        print("hey")
    }
    
    var listener: ListenerRegistration?
    var recentMessagesDictionary = [String: RecentMessage]()
    fileprivate func fetchRecentMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let query = Firestore.firestore().collection("matches_messages").document(currentUserId).collection("recent_messages")
        listener = query.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Failed to fetch recent messages:", err)
                return
            }
            
            querySnapshot?.documentChanges.forEach({ (change) in
                if change.type == .added || change.type == .modified {
                    let dictionary = change.document.data()
                    let recentMessage = RecentMessage(dictionary: dictionary)
                    self.recentMessagesDictionary[recentMessage.uid] = recentMessage
                }
            })
            self.resetItems()
        }
    }
    
    func resetItems() {
        let values = Array(recentMessagesDictionary.values)
        items = values.sorted(by: { rm1, rm2 in
            return rm1.timestamp.compare(rm2.timestamp) == .orderedDescending
        })
        collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recentMessage = items[indexPath.item]
        let dictionary = ["name": recentMessage.name, "profileImageUrl": recentMessage.profileImageUrl, "uid": recentMessage.uid]
        let match = Match(dictionary: dictionary)
        let controller = ChatLogController(match: match)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    fileprivate func setupUI() {
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: 150))
        collectionView.contentInset.top = 150
        collectionView.verticalScrollIndicatorInsets.top = 150
        
        let statusBarCover = UIView(backgroundColor: .white)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 16, right: 0)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
}
