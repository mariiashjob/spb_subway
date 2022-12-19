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
    static let coefficient = 0.01
    static let lineWidth = 3.0
    static let lineCap = CGLineCap.round
    static let alphaEnabled = 1.0
    static let alphaDisabled = 0.2
    static let fontSize = 7.0
    static let fontLargeSize = 15.0
}

struct MapScaleConstants {
    static let duration = 0.6
    static let delay = 0.0
    static let originScale = 1.0
}

struct FooterAnimation {
    static let duration = 0.5
    static let delay = 0.0
    static let damping = 1.0
    static let velocity = 0.3
}

struct AttributesConstants {
    static let cornerRadius = 10.0
    static let alpha = 0.8
    static let spacing = 20.0
}

struct Texts {
    static let fromText = "Откуда:"
    static let toText = "Куда:"
    static let fromStation = "A"
    static let toStation = "B"
    static let transfer = "Сделайте пересадку"
}

struct Colors {
    static let backgroundColor = UIColor.darkGray
    static let backgroundHighlightedColor = UIColor.systemGray
    static let textColor = UIColor.white
    static let textHighlightedColor = UIColor.systemYellow
    static let textDisabledColor = UIColor.systemGray
}

struct Symbols {
    static let bullet: String = "\u{2022}"
    static let whiteTriangle: String = "\u{25B7}"
    static let blackTriangle: String = "\u{25B6}"
}

enum Images: String {
    case line = "line"
}

struct CardsAttributes {
    static let pointWidth: CGFloat = 5.0
    static let pointHeight: CGFloat = 5.0
    static let pointsViewHeight: CGFloat = 5.0
    static let cardHeight: CGFloat = 80.0
    static let leftDistancetoView: CGFloat = 0.0
    static let rightDistancetoView: CGFloat = 0.0
    static let topDistancetoView: CGFloat = 10.0
    static let bottomDistancetoView: CGFloat = 0.0
    static let minimumLineSpacing: CGFloat = 0.0
}
