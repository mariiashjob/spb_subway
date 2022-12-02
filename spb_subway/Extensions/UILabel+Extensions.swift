//
//  UILabel+Extensions.swift
//  spb_subway
//
//  Created by m.shirokova on 03.12.2022.
//

import UIKit

extension UILabel {
    
    static let defaultWidth: CGFloat = 100.0
    static let defaultHeight: CGFloat = 30.0
    
    func width(char: String = " ") -> CGFloat {
        guard
            let text = self.text,
            let count = text.components(separatedBy: char).map({ $0.count }).max()
        else {
            return UILabel.defaultWidth
        }
        return CGFloat(count) * self.font.pointSize
    }
    
    func height(char: String = " ") -> CGFloat {
        guard
            let text = self.text
        else {
            return UILabel.defaultHeight
        }
        let lines = CGFloat(text.components(separatedBy: char).count)
        return lines * self.font.lineHeight * 2.0
    }
}
