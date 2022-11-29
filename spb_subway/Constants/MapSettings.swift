//
//  MapSettings.swift
//  spb_subway
//
//  Created by m.shirokova on 17.11.2022.
//

import UIKit

struct City {
    static let spb = "Санкт-Петербург"
}

struct MapSettings {
    static let lineWidth = 4.0
    static let lineCap = CGLineCap.round
    static let alphaEnabled = 1.0
    static let alphaDisabled = 0.3
}

struct MapScaleConstants {
    static let duration = 0.6
    static let delay = 0.0
    static let originScale = 1.0
}

struct AttributesConstants {
    static let cornerRadius = 10.0
    static let alpha = 0.8
}

struct Texts {
    static let fromText = "From:"
    static let toText = "To:"
}

struct Colors {
    static let backgroundColor = UIColor.darkGray
    static let backgroundHighlightedColor = UIColor.systemGray
    static let textColor = UIColor.white
    static let textHighlightedColor = UIColor.systemYellow
    static let textDisabledColor = UIColor.systemGray
}
