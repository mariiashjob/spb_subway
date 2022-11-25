//
//  SearchField.swift
//  spb_subway
//
//  Created by m.shirokova on 16.11.2022.
//

import UIKit
import SwiftUI

class SearchField: UITextField {
    
    var textPadding = UIEdgeInsets(
        top: 5,
        left: 10,
        bottom: 5,
        right: 10
    )
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for view in subviews {
            if let button = view as? UIButton {
                let image = UIImage(named: "close")
                button.setBackgroundImage(image, for: UIControl.State.normal)
                button.alpha = AttributesConstants.alpha
            }
        }
    }
    
    override func awakeFromNib() {
        
        self.textColor = Colors.textColor
        self.backgroundColor = Colors.backgroundColor
        self.layer.cornerRadius = AttributesConstants.cornerRadius
        self.clipsToBounds = true
        self.clearButtonMode = .always
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}
