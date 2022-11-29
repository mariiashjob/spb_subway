//
//  MapContentView.swift
//  spb_subway
//
//  Created by m.shirokova on 16.11.2022.
//

import UIKit

class MapContentView: UIView, UITextFieldDelegate, MapViewDelegate {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var directionFieldsView: UIView!
    @IBOutlet weak var fromTextField: SearchField!
    @IBOutlet weak var toTextField: SearchField!
    @IBOutlet weak var lineImageView: UIImageView!
    @IBOutlet weak var changeButton: UIButton!
    private lazy var currentField: UITextField? = nil
    private lazy var currentMapFrame: CGRect? = nil
    private var searchFieldView: UIView? = nil
    private var searchLabel: UILabel? = nil
    let map = MapView()
    var searchField: SearchField? = nil
    var isKeyboardUp: Bool = false
    var keyboardHeight: CGFloat = 0.0
    
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
        
        map.delegate = self
        fromTextField.delegate = self
        toTextField.delegate = self
        fromTextField.attributedPlaceholder = attributedPlaceholder(text: Texts.fromText)
        toTextField.attributedPlaceholder = attributedPlaceholder(text: Texts.toText)
        footerView.layer.cornerRadius = AttributesConstants.cornerRadius
        contentView.layer.cornerRadius = AttributesConstants.cornerRadius
        contentView.addSubview(map)
        map.frame = mapFrame
        lineImageView.image = UIImage(named: "line")
        lineImageView.backgroundColor = nil
        configureFooterView()
        addGestures()
        // TODO: bug - stations are not highlighted after foreground app state
    }
    
    @discardableResult
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch(textField as? SearchField) {
        case fromTextField:
            map.routeWatcher.clearStationFrom()
            // TODO: Bug - fields are jumping while clear one of them
            //showSearchField(placeholder: textField.placeholder)
        case toTextField:
            map.routeWatcher.clearStationto()
            //showSearchField(placeholder: textField.placeholder)
        case searchField:
            searchField?.text = nil
            map.routeWatcher.clearCurrentDirection()
        default:
            return false
        }
        map.updateMapCurrentView()
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
                if let selectedStation = map.stations.filter({ station in
                    station.name?.removeSpaces() == text.removeSpaces()
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
        map.updateMapCurrentView()
        directionFieldsView.alpha = 1
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
        map
            .updateMapCurrentView()
            .routeWatcher.changeStations()
    }
    
    @objc private func didTap(_ gester: UITapGestureRecognizer) {
        currentField = gester.view as? SearchField
        guard let currentField = currentField, let placeholder = currentField.placeholder else {
            return
        }
        showSearchField(placeholder: placeholder)
    }

    @objc private func didPan(_ gester: UIPanGestureRecognizer) {
        let translation = gester.translation(in: self)
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
        let footerViewHeight = 100.0
        if isKeyboardUp {
            footerView.frame = CGRect(
                x: 0,
                y: self.bounds.height - keyboardHeight - (footerViewHeight - AttributesConstants.cornerRadius),
                width: self.bounds.width,
                height: footerViewHeight
            )
        } else {
            footerView.frame = CGRect(
                x: 0,
                y: self.bounds.height - footerViewHeight,
                width: self.bounds.width,
                height: footerViewHeight
            )
        }
    }
    
    private func attributedPlaceholder(text: String, color: UIColor = Colors.textDisabledColor) -> NSAttributedString {
        return NSAttributedString(
            string: text,
            attributes: [NSAttributedString.Key.foregroundColor: color]
        )
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
    }
    
    private func showSearchField(placeholder: String?) {
        map.routeWatcher.updateCurrentDirection(currentField == fromTextField)
        // TODO: add animations for all alpha events
        directionFieldsView.alpha = 0
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
            width: stackView.bounds.width,
            height: stackView.bounds.height
        )
        searchFieldView.layer.borderWidth = 1.0
        searchFieldView.layer.borderColor = Colors.backgroundColor.cgColor
        searchFieldView.backgroundColor = Colors.textHighlightedColor
        searchFieldView.layer.cornerRadius = AttributesConstants.cornerRadius
        searchFieldView.clipsToBounds = true
        stackView.addSubview(searchFieldView)
    }
    
    private func configureSearchField(direction: String?) {
        // TODO: add animation
        searchLabel = UILabel()
        searchField = SearchField()
        guard let searchField = searchField, let searchFieldView = searchFieldView, let searchLabel = searchLabel else {
            return
        }
        searchLabel.text = direction
        searchLabel.textAlignment = .center
        searchLabel.textColor = Colors.backgroundColor
        searchField.delegate = self
        let bounds = stackView.bounds
        searchLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: 60.0,
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
