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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            scrollView.contentSize = CGSize(width: self.view.bounds.width, height: height * 1.3)
        }
        self.view.addSubview(scrollView)
        mapContentView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.bounds.width,
            height: scrollViewHeight!
        )
    }
}
