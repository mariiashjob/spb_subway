//
//  UIButton+Extension.swift
//  spb_subway
//
//  Created by m.shirokova on 06.12.2022.
//

import UIKit

extension UIButton {
    
    func addBackgroundImage(name: String) {
        let image = UIImage(named: name)
        self.setBackgroundImage(image, for: UIControl.State.highlighted)
        self.backgroundColor = Colors.backgroundColor
        self.alpha = AttributesConstants.alpha
    }
}
