//
//  Extensions+Extensions.swift
//  spb_subway
//
//  Created by m.shirokova on 25.11.2022.
//

import UIKit

extension String {
    
    func removeSpaces() -> String {
        return self.replacingOccurrences(of: " ", with: "").lowercased()
    }
    
    func attributedPlaceholder(color: UIColor = Colors.textDisabledColor) -> NSAttributedString {
        return NSAttributedString(
            string: self,
            attributes: [NSAttributedString.Key.foregroundColor: color]
        )
    }
}
