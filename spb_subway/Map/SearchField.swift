//
//  SearchField.swift
//  spb_subway
//
//  Created by m.shirokova on 16.11.2022.
//

import UIKit
import SwiftUI

class SearchField: UITextField {
    
    override func awakeFromNib() {
        self.textColor = .systemTeal
        self.layer.cornerRadius = 10
    }
}
