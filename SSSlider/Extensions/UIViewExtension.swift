//
//  UIViewExtension.swift
//  SSSlider
//
//  Created by Noa Fredman on 23/03/2022.
//

import UIKit

extension UIView {
    
    enum AnchorX {
        case leading
        case trailing
    }
    
    func setAnchor(anchor: AnchorX,
                                           constant: CGFloat,
                                           toView: UIView? = nil,
                                           toAnchor: AnchorX? = nil) {
        guard let view = toView ?? self.superview else {
            return
        }
        let viewAnchor: NSLayoutXAxisAnchor?
        switch toAnchor {
        case .leading:
            viewAnchor = view.leadingAnchor
        case .trailing:
            viewAnchor = view.trailingAnchor
        case .none:
            viewAnchor = nil
        }
        switch anchor {
        case .leading:
            setAnchorX(anchor: self.leadingAnchor,
                       constant: constant,
                       toView: view,
                       toAnchor: viewAnchor ?? view.leadingAnchor)
        case .trailing:
            setAnchorX(anchor: self.trailingAnchor,
                       constant: constant,
                       toView: view,
                       toAnchor: viewAnchor ?? view.trailingAnchor)
        }
    }
    
    private func setAnchorX<T>(anchor: NSLayoutAnchor<T>,
                           constant: CGFloat,
                           toView: UIView,
                                                  toAnchor: NSLayoutAnchor<T>) {
        
        if let first = self.constraints.first(where: {
            ($0.firstAnchor == anchor || $0.secondAnchor == anchor) && ($0.firstItem as? NSObject == self || $0.secondItem as? NSObject == self)
        }) {
            first.constant = constant
        } else {
            anchor.constraint(equalTo: toAnchor, constant: constant).isActive = true
        }
                                                      
    }
}
