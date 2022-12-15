//
//  CardsView.swift
//  spb_subway
//
//  Created by m.shirokova on 14.12.2022.
//

import UIKit

final class CardsView: UIView {
    
    var routeWatcher: RouteWatcher?
    let leftView = UIView()
    let centerView = UIView()
    let rightView = UIView()
    private lazy var centerX = self.frame.size.width / 2
    private lazy var centerY = self.frame.size.height / 2
    private lazy var cardWidth = self.bounds.width / 3
    private lazy var selfCenter = CGPoint(x: centerX, y: centerY)
    private var views = [UIView]()
    private lazy var points = [
        CGPoint(x: centerX - cardWidth, y: self.center.y),
        selfCenter,
        CGPoint(x: centerX + cardWidth, y: self.center.y)
    ]
    private var currentDirection: UISwipeGestureRecognizer.Direction? = nil
    private var isAnimationNeeded = false
    
    convenience init(_ routeWatcher: RouteWatcher?) {
        self.init(frame: CGRect.zero)
        self.routeWatcher = routeWatcher
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateViews()
        addGestures()
        updateRouteCards()
    }
    
    func updateRouteCards() {
        guard let routeWatcher = routeWatcher else {
            return
        }
        let width = self.bounds.width / 3 * 0.95
        let height = self.bounds.height * 0.9
        let frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: height
        )
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        if routeWatcher.routes.count > 1 {
            for (index, point) in points.enumerated() {
                if (index == 0 && currentDirection == .left) || (index == 0 && currentDirection == .right) {
                    let view = views[index]
                    view.frame = frame
                    view.center = point
                    view.layer.borderWidth = 1.0
                    view.layer.borderColor = Colors.backgroundColor.cgColor
                    view.layer.cornerRadius = AttributesConstants.cornerRadius
                    view.clipsToBounds = true
                    self.addSubview(view)
                } else {
                    if isAnimationNeeded {
                        UIView.animate(
                            withDuration: FooterAnimation.duration,
                            delay: FooterAnimation.delay,
                            usingSpringWithDamping: FooterAnimation.damping,
                            initialSpringVelocity: FooterAnimation.velocity,
                            options: [.beginFromCurrentState],
                            animations: {
                                let view = self.views[index]
                                view.frame = frame
                                view.center = point
                                view.layer.borderWidth = 1.0
                                view.layer.borderColor = Colors.backgroundColor.cgColor
                                view.layer.cornerRadius = AttributesConstants.cornerRadius
                                view.clipsToBounds = true
                                self.addSubview(view)
                            })
                    } else {
                        let view = views[index]
                        view.frame = frame
                        view.center = point
                        view.layer.borderWidth = 1.0
                        view.layer.borderColor = Colors.backgroundColor.cgColor
                        view.layer.cornerRadius = AttributesConstants.cornerRadius
                        view.clipsToBounds = true
                        self.addSubview(view)
                    }
                    isAnimationNeeded = false
                }
            }
        } else {
            let view = centerView
            view.frame = frame
            view.center = selfCenter
            view.layer.borderWidth = 1.0
            view.layer.borderColor = Colors.backgroundColor.cgColor
            view.layer.cornerRadius = AttributesConstants.cornerRadius
            view.clipsToBounds = true
            self.addSubview(view)
        }
    }
    
    private func addGestures() {
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeCard(_:)))
        swipeGestureLeft.direction = .left
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeCard(_:)))
        swipeGestureRight.direction = .right
        self.addGestureRecognizer(swipeGestureLeft)
        self.addGestureRecognizer(swipeGestureRight)
    }
    
    private func updateViews() {
        guard views.isEmpty else {
            return
        }
        var countViews = 0
        guard let routeWatcher = routeWatcher, !routeWatcher.routes.isEmpty else {
            return
        }
        if routeWatcher.routes.count == 1 {
            countViews = 1
        } else if routeWatcher.routes.count > 1 {
            countViews = 3
        }
        for _ in 1...countViews {
            let view = UIView()
            views.append(view)
        }
    }
    
    private func leftRouteId() -> Int {
        guard let routeWatcher = routeWatcher else {
            return 0
        }
        return routeWatcher.routeId == 0 ? routeWatcher.routes.count - 1 : routeWatcher.routeId - 1
    }
    
    private func rightRouteId() -> Int {
        guard let routeWatcher = routeWatcher else {
            return 0
        }
        return routeWatcher.routeId == routeWatcher.routes.count - 1 ? 0 : routeWatcher.routeId + 1
    }
    
    private func moveSubview() {
        guard let currentDirection = currentDirection else {
            return
        }
        var temp: [UIView] = []
        switch(currentDirection) {
        case .left:
            for (index, view) in views.enumerated() {
                if index != 0 {
                    temp.append(view)
                }
            }
            if let first = views.first {
                temp.append(first)
            }
            views = temp
        case .right:
            if let last = views.last {
                temp.append(last)
            }
            for (index, view) in views.enumerated() {
                if index != views.count - 1 {
                    temp.append(view)
                }
            }
            views = temp
        default:
            return
        }
        layoutSubviews()
    }
    
    @objc private func didSwipeCard(_ gesture: UISwipeGestureRecognizer) {
        guard
            let routeWatcher = routeWatcher,
            routeWatcher.routes.count > 1
        else {
            return
        }
        currentDirection = gesture.direction
        let maxRouteId = routeWatcher.routes.count - 1
        if gesture.direction == .left {
            if routeWatcher.routeId == maxRouteId {
                routeWatcher.updateRoute(id: 0)
            } else {
                routeWatcher.updateRoute(value: 1)
            }
        } else if gesture.direction == .right {
            if routeWatcher.routeId == 0 {
                routeWatcher.updateRoute(id: maxRouteId)
            } else {
                routeWatcher.updateRoute(value: -1)
            }
        } else {
            return
        }
        isAnimationNeeded = true
        moveSubview()
    }
}
