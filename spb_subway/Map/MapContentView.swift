//
//  MapContentView.swift
//  spb_subway
//
//  Created by m.shirokova on 16.11.2022.
//

import UIKit
import SwiftUI

class MapContentView: UIView, UITextFieldDelegate, UIGestureRecognizerDelegate, MapViewDelegate {
    
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var fieldsView: UIStackView!
    @IBOutlet weak var lineImageView: UIImageView!
    @IBOutlet weak var directionFieldsView: UIView!
    @IBOutlet weak var fromTextField: SearchField!
    @IBOutlet weak var toTextField: SearchField!
    @IBOutlet weak var infoView: UIView!
    private var currentField: UITextField?
    private var currentMapFrame: CGRect?
    private var searchFieldView: UIView?
    private var searchLabel: UILabel?
    var searchField: SearchField?
    var isKeyboardUp: Bool = false
    var isFooterUp: Bool = false
    var isFooterUpdated: Bool = true
    var keyboardHeight: CGFloat = 0.0
    let map = MapView()
    lazy var routesView = RoutesView(routeWatcher: self.map.routeWatcher)
    
    private var mapFrame: CGRect {
        if let frame = currentMapFrame {
            return frame
        } else {
            return CGRect(
                x: 0,
                y: 0,
                width: contentView.bounds.width,
                height: contentView.bounds.height
            )
        }
    }
    
    lazy var isFromFieldSelected: Bool = {
        if currentField == fromTextField || currentField == nil {
            return true
        } else {
            return false
        }
    }()
    
    static func loadFromNib() -> MapContentView {
        let nib = UINib(nibName: "MapContentView", bundle: nil)
        return nib.instantiate(withOwner: self).first as! MapContentView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        routesView.delegate = self
        map.delegate = self
        fromTextField.delegate = self
        toTextField.delegate = self
        fromTextField.attributedPlaceholder = Texts.fromText.attributedPlaceholder()
        fromTextField.clearButtonMode = .never
        toTextField.attributedPlaceholder = Texts.toText.attributedPlaceholder()
        toTextField.clearButtonMode = .never
        footerView.layer.cornerRadius = AttributesConstants.cornerRadius
        contentView.layer.cornerRadius = AttributesConstants.cornerRadius
        contentView.addSubview(map)
        map.frame = mapFrame
        lineImageView.image = UIImage(named: Images.line.rawValue)
        lineImageView.backgroundColor = nil
        lineImageView.isUserInteractionEnabled = true
        addGestures()
        configureFooterView()
        if !map.routeWatcher.routes.isEmpty {
            infoView.addSubview(routesView)
        }
        addGestures()
        // TODO: bug - stations are not highlighted after foreground app state
    }
    
    @discardableResult
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch(textField as? SearchField) {
        case fromTextField:
            map.routeWatcher.clearStationFrom()
        case toTextField:
            map.routeWatcher.clearStationto()
        case searchField:
            searchField?.text = nil
            map.routeWatcher.clearCurrentDirection()
        default:
            return false
        }
        map.updateMapLabels()
        isFooterUp = false
        return true
    }
    
    @discardableResult
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let currentField = currentField else {
            return false
        }
        // TODO: add animations for all alpha events
        if let searchField = searchField, let searchFieldView = searchFieldView {
            searchFieldView.alpha = 0
            if let text = searchField.text {
                if let selectedStation = map.subway.stations.filter({ station in
                    station.name.removeSpaces() == text.removeSpaces()
                }).first {
                    currentField.text = text
                    let isFromStation = map.routeWatcher.currentDirection?.isFromStation ?? true
                    let direction = Direction(
                        station: selectedStation,
                        isFromStation: isFromStation
                    )
                    map.routeWatcher
                        .updateCurrentDirection(direction)
                        .saveStation()
                        .clearCurrentDirection()
                }
            }
        }
        // TODO: Bug - current station does not disappear from map after return with keyboard
        map.updateMapLabels()
        directionFieldsView.alpha = 1
        lineImageView.alpha = 1
        isFooterUp = false
        return self.endEditing(true)
        // TODO: Bug - keyboard is not closed after done button pressed while seaarch field has not been edited
    }
    
    internal func followKeyboard(isKeyboardUp: Bool, keyboardHeight: CGFloat = 0.0) {
        self.isKeyboardUp = isKeyboardUp
        self.keyboardHeight = keyboardHeight
        layoutSubviews()
    }
    
    @IBAction func changeDirections(_ sender: Any) {
        fromTextField.text = map.routeWatcher.stationTo?.name
        toTextField.text = map.routeWatcher.stationFrom?.name
        isFooterUpdated = false
        map
            .updateMapLabels()
            .routeWatcher.changeStations()
    }
    
    @objc private func didSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard !map.routeWatcher.routes.isEmpty else {
            return
        }
        if isFooterUp && gesture.direction == .down {
            isFooterUp = false
        } else if !isFooterUp && gesture.direction == .up {
            isFooterUp = true
        }
        isFooterUpdated = true
        map.updateMapContent()
        layoutSubviews()
    }
    
    @objc private func didTap(_ gesture: UITapGestureRecognizer) {
        currentField = gesture.view as? SearchField
        guard let currentField = currentField, let placeholder = currentField.placeholder else {
            return
        }
        showSearchField(placeholder: placeholder)
    }

    @objc private func didPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        UIView.animate(withDuration: MapScaleConstants.duration, delay: MapScaleConstants.delay, animations: {
            self.map.frame = CGRect(
                x: translation.x,
                y: translation.y,
                width: self.map.bounds.width,
                height: self.map.bounds.height
            )
        })
        currentMapFrame = map.frame
    }
    
    @objc private func didPinch(_ gester: UIPinchGestureRecognizer) {
        if gester.state == .changed {
            let scale = gester.scale
            if scale < MapScaleConstants.originScale {
                UIView.animate(withDuration: MapScaleConstants.duration, delay: MapScaleConstants.delay, animations: {
                    self.scaleMapView(scaleX: scale, y: scale)
                }, completion: { isCompleted in
                    if isCompleted {
                        UIView.animate(withDuration: MapScaleConstants.duration, delay: MapScaleConstants.delay, options: [UIView.AnimationOptions.curveLinear], animations: {
                            self.scaleMapView(scaleX: MapScaleConstants.originScale, y: MapScaleConstants.originScale)
                            self.map.frame = CGRect(
                                x: 0,
                                y: 0,
                                width: self.map.bounds.width,
                                height: self.map.bounds.height
                            )
                        }, completion: nil)
                    }
                })
            } else {
                UIView.animate(withDuration: MapScaleConstants.duration, delay: MapScaleConstants.delay, options: [], animations: {
                    self.scaleMapView(scaleX: scale, y: scale)
                })
            }
        }
        currentMapFrame = map.frame
    }
    
    internal func updateRouteInfo() {
        routesView.updateRouteInfo(subway: map.subway, routeId: map.routeWatcher.routeId, isFooterUp: isFooterUp)
        routesView.routeDetailsView
            .redrawDetailedRoute(
                subway: map.subway, routeId: map.routeWatcher.routeId)
        map.updateMapContent()
    }
    
    internal func updateCurrentStationField(station: Station?) {
        guard let searchField = searchField else {
            return
        }
        if let station = station {
            searchField.text = station.name
        } else {
            searchField.text = ""
        }
    }
    
    private func configureFooterView() {
        var footerViewHeight = 100.0
        if isKeyboardUp {
            footerView.frame = CGRect(
                x: 0,
                y: self.bounds.height - keyboardHeight - (footerViewHeight - AttributesConstants.cornerRadius),
                width: self.bounds.width,
                height: footerViewHeight)
            infoView.alpha = 0
        } else if map.routeWatcher.routes.isEmpty {
            UIView.animate(
                withDuration: FooterAnimation.duration,
                delay: FooterAnimation.delay,
                usingSpringWithDamping: FooterAnimation.damping,
                initialSpringVelocity: FooterAnimation.velocity,
                options: [.beginFromCurrentState, .transitionCurlDown],
                animations: {
                    self.footerView.frame = CGRect(
                        x: 0,
                        y: self.bounds.height - footerViewHeight,
                        width: self.bounds.width,
                        height: footerViewHeight)
                    self.infoView.alpha = 0
            })
        } else if isFooterUp {
            if isFooterUpdated {
                UIView.animate(
                    withDuration: FooterAnimation.duration,
                    delay: FooterAnimation.delay,
                    usingSpringWithDamping: FooterAnimation.damping,
                    initialSpringVelocity: FooterAnimation.velocity,
                    options: [.beginFromCurrentState],
                    animations: {
                    self.footerView.frame = CGRect(
                        x: 0,
                        y: footerViewHeight,
                        width: self.bounds.width,
                        height: self.bounds.height)
                    self.infoView.alpha = 1
                    self.routesView.detailsScrollView.alpha = 1
                })
            } else {
                self.footerView.frame = CGRect(
                    x: 0,
                    y: footerViewHeight,
                    width: self.bounds.width,
                    height: self.bounds.height)
                self.infoView.alpha = 1
                self.routesView.detailsScrollView.alpha = 1
            }
            
        } else {
            footerViewHeight *= 2
            if isFooterUpdated {
                UIView.animate(
                    withDuration: FooterAnimation.duration,
                    delay: FooterAnimation.delay,
                    usingSpringWithDamping: FooterAnimation.damping,
                    initialSpringVelocity: FooterAnimation.velocity,
                    options: [.beginFromCurrentState, .transitionCurlDown],
                    animations: {
                    self.footerView.frame = CGRect(
                        x: 0,
                        y: self.bounds.height - footerViewHeight,
                        width: self.bounds.width,
                        height: footerViewHeight)
                    self.infoView.alpha = 1
                    self.routesView.detailsScrollView.alpha = 0
                })
            } else {
                self.footerView.frame = CGRect(
                    x: 0,
                    y: self.bounds.height - footerViewHeight,
                    width: self.bounds.width,
                    height: footerViewHeight)
                self.infoView.alpha = 1
                self.routesView.detailsScrollView.alpha = 0
            }
        }
    }
    
    private func addGestures() {
        let pinchGecture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        let panGecture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        let tapFromfieldGecture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        let tapToFieldGecture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        contentView.addGestureRecognizer(pinchGecture)
        contentView.addGestureRecognizer(panGecture)
        fromTextField.addGestureRecognizer(tapFromfieldGecture)
        toTextField.addGestureRecognizer(tapToFieldGecture)
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeUpGesture.direction = .up
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeDownGesture.direction = .down
        lineImageView.addGestureRecognizer(swipeUpGesture)
        lineImageView.addGestureRecognizer(swipeDownGesture)
    }
    
    private func showSearchField(placeholder: String?) {
        map.routeWatcher.updateCurrentDirection(currentField == fromTextField)
        // TODO: add animations for all alpha events
        directionFieldsView.alpha = 0
        lineImageView.alpha = 0
        if let searchFieldView = searchFieldView, let searchField = searchField {
            searchFieldView.alpha = 1
            searchLabel?.text = placeholder
            searchField.text = map.routeWatcher.currentDirection?.station?.name ?? ""
        } else {
            configureSearchFieldView()
            configureSearchField(direction: placeholder)
        }
        // TODO: Bug - keyboard does not appear after clearing text fields
        searchField?.delegate = self
        searchField?.becomeFirstResponder()
    }
    
    private func configureSearchFieldView() {
        searchFieldView = UIView()
        guard let searchFieldView = searchFieldView else {
            return
        }
        searchFieldView.frame = CGRect(
            x: 0,
            y: 0,
            width: fieldsView.bounds.width,
            height: fieldsView.bounds.height
        )
        searchFieldView.layer.borderWidth = 1.0
        searchFieldView.layer.borderColor = Colors.backgroundColor.cgColor
        searchFieldView.backgroundColor = Colors.textHighlightedColor
        searchFieldView.layer.cornerRadius = AttributesConstants.cornerRadius
        searchFieldView.clipsToBounds = true
        fieldsView.addSubview(searchFieldView)
    }
    
    private func configureSearchField(direction: String?) {
        searchLabel = UILabel()
        searchField = SearchField()
        guard let searchField = searchField, let searchFieldView = searchFieldView, let searchLabel = searchLabel else {
            return
        }
        searchLabel.text = direction
        searchLabel.textAlignment = .center
        searchLabel.textColor = Colors.backgroundColor
        searchField.delegate = self
        let bounds = fieldsView.bounds
        searchLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: searchLabel.width(),
            height: bounds.height
        )
        let searchLabelWidth = searchLabel.bounds.width
        searchField.frame = CGRect(
            x: 0 + searchLabelWidth,
            y: 0,
            width: bounds.width - searchLabelWidth,
            height: bounds.height
        )
        searchField.returnKeyType = .done
        searchField.clearButtonMode = .always
        searchField.clipsToBounds = true
        searchField.layer.cornerRadius = AttributesConstants.cornerRadius
        searchField.backgroundColor = Colors.textHighlightedColor
        searchField.text = map.routeWatcher.currentDirection?.station?.name ?? ""
        searchFieldView.addSubview(searchLabel)
        searchFieldView.addSubview(searchField)
    }
    
    private func scaleMapView(scaleX: CGFloat, y: CGFloat) {
        self.contentView.transform = CGAffineTransform(scaleX: scaleX, y: y)
    }
}
