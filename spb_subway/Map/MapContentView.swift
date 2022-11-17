//
//  MapContentView.swift
//  spb_subway
//
//  Created by m.shirokova on 16.11.2022.
//

import UIKit

class MapContentView: UIView {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    
    private let map = MapView()
    
    static func loadFromNib() -> MapContentView {
        let nib = UINib(nibName: "MapContentView", bundle: nil)
        return nib.instantiate(withOwner: self).first as! MapContentView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        headerView.layer.cornerRadius = AttributesConstants.cornerRadius
        headerView.alpha = AttributesConstants.headerAlpha
        mapView.layer.cornerRadius = AttributesConstants.cornerRadius
        mapView.addSubview(map)
        map.frame = CGRect(
            x: 0,
            y: 0,
            width: mapView.bounds.width,
            height: mapView.bounds.height
        )
        addGesture()
    }
    
    func addGesture() {
        let pinchGecture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        mapView.addGestureRecognizer(pinchGecture)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else {
            return
        }
        // print("Point: \(String(describing: point))")
        // todo: moving the map view
        // setNeedsDisplay()
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
                        }, completion: nil)
                    }
                })
            } else {
                UIView.animate(withDuration: MapScaleConstants.duration, delay: MapScaleConstants.delay, options: [], animations: {
                    self.scaleMapView(scaleX: scale, y: scale)
                })
            }
        }
    }
    
    private func scaleMapView(scaleX: CGFloat, y: CGFloat) {
        self.mapView.transform = CGAffineTransform(scaleX: scaleX, y: y)
    }
}
