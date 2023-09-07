//
//  SwipingPhotosController.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 04.05.23.
//

import UIKit

class SwipingPhotosController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var cardViewModel: CardViewModel! {
        didSet {
            controllers = cardViewModel.imageNames.map({ (imageUrl) -> UIViewController in
                let photoController = PhotoController(imageUrl: imageUrl)
                return photoController
            })
            setViewControllers([controllers.first!], direction: .forward, animated: true)
            
            setupBarViews()
        }
    }
    
    fileprivate let barStackView = UIStackView(arrangedSubviews: [])
    fileprivate let deselectedBarColor = UIColor(white: 0, alpha: 0.1)
    
    fileprivate func setupBarViews() {
        
        cardViewModel.imageNames.forEach { _ in
            let barView = UIView()
            barView.backgroundColor = deselectedBarColor
            barView.layer.cornerRadius = 2
            barStackView.addArrangedSubview(barView)
        }
        
        
        
        barStackView.spacing = 4
        barStackView.distribution = .fillEqually
        barStackView.arrangedSubviews.first?.backgroundColor = .white
        view.addSubview(barStackView)
        
        var paddingTop: CGFloat = 15
        if !isCardViewMode {
            paddingTop -= UIApplication.shared.statusBarFrame.height
        }
        
        barStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: paddingTop, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let currentPhotoController = viewControllers?.first
        if let index = controllers.firstIndex(where: {$0 == currentPhotoController}) {
            barStackView.arrangedSubviews.forEach { $0.backgroundColor = deselectedBarColor }
            barStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }
    
    var controllers = [UIViewController]()
    
    fileprivate let isCardViewMode: Bool
    
    init(isCardViewMode: Bool = false) {
        self.isCardViewMode = isCardViewMode
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        view.backgroundColor = .white
        dataSource = self
        
        disableSwipingAbility()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
        let currentController = viewControllers!.first!
        let tapLocation = gesture.location(in: nil)
        barStackView.arrangedSubviews.forEach { $0.backgroundColor = deselectedBarColor }
        
        if let index = controllers.firstIndex(of: currentController) {
            if tapLocation.x > view.frame.width / 2 {
                let nextIndex = min(index + 1, controllers.count - 1)
                let nextController = controllers[nextIndex]
                setViewControllers([nextController], direction: .forward, animated: false)
                barStackView.arrangedSubviews[nextIndex].backgroundColor = .white
            } else {
                let prevIndex = max(0, index - 1)
                let prevController = controllers[prevIndex]
                setViewControllers([prevController], direction: .forward, animated: false)
                barStackView.arrangedSubviews[prevIndex].backgroundColor = .white
            }
        }
    }
    
    fileprivate func disableSwipingAbility() {
        view.subviews.forEach { v in
            if let v = v as? UIScrollView {
                v.isScrollEnabled = false
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == 0 { return nil }
        return controllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == controllers.count - 1 { return nil }
        return controllers[index + 1]
    }
}

