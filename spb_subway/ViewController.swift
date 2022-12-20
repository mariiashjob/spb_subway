//
//  ViewController.swift
//  spb_subway
//
//  Created by m.shirokova on 15.11.2022.
//

import UIKit

class ViewController: UIViewController {
    
    private var scrollView = UIScrollView()
    private let mapContentView = MapContentView.loadFromNib()
    private var scrollViewHeight: CGFloat? = nil
    private var lines: [Line] = []
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if self.mapContentView.map.subway.lines.isEmpty {
            SubwayLoader.getSpbSubwayLines { lines in
                self.mapContentView.map.subway.lines = lines
                self.mapContentView.map.updateMapContent()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            
        configureContent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureContent()
    }
    
    private func configureContent() {
        if let height = scrollViewHeight {
            scrollView = UIScrollView(frame: CGRect(
                x: 0,
                y: 0,
                width: self.view.bounds.width,
                height: height
            ))
        } else {
            scrollView = UIScrollView(frame: self.view.bounds)
            scrollViewHeight = mapContentView.bounds.height
        }
        scrollView.addSubview(mapContentView)
        if let height = scrollViewHeight {
            scrollView.contentSize = CGSize(width: self.view.bounds.width, height: height)
        }
        self.view.addSubview(scrollView)
        mapContentView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.bounds.width,
            height: self.view.bounds.height
        )
        mapContentView.routesView.layoutSubviews()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            mapContentView.followKeyboard(isKeyboardUp: true, keyboardHeight: keyboardSize.height)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        mapContentView.followKeyboard(isKeyboardUp: false)
    }
}
