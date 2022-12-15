//
//  CardView.swift
//  spb_subway
//
//  Created by m.shirokova on 15.12.2022.
//

import UIKit

final class CardView: UIView {
    
    var route: Route?
    
    convenience init(_ route: Route?) {
        self.init(frame: CGRect.zero)
        self.route = route
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
