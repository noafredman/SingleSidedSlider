//
//  SSSlider.swift
//
//  Created by Noa Fredman on 26/02/2022.
//  Copyright © 2022 Noa Fredman.
//

//  Based upon:
//  https://github.com/codeit-ios/DSSlider
//
//  Copyright (c) 2020 Konstantin Stolyarenko
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

public enum SSSliderPosition {
    case left
    case right
    
    public func getBoolValue() -> Bool {
        switch self {
        case .left:
            return false
        case .right:
            return true
        }
    }
}

public enum SlidingDirection {
    case left
    case right
}

public protocol SSSliderDelegate: class {
    func sliderDidFinishSliding(_ slider: SSSlider, at position: SSSliderPosition)
}

// MARK: SSSlider

public class SSSlider: UIView {
    
    struct Constants {
        static let sliderEndPoint: CGFloat = 80
    }
    // MARK: Public Properties
    
    // MARK: Views
    
    @IBOutlet var sliderView: UIView!
    @IBOutlet weak var sliderBackgroundView: UIView!
    @IBOutlet weak var sliderBackgroundViewTextLabel: UILabel!
    @IBOutlet weak var leadingConstraint_sliderDraggedViewLabel: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint_sliderDraggedView: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint_sliderDraggedView: NSLayoutConstraint!
    @IBOutlet weak var sliderDraggedView: UIView!
    @IBOutlet weak var sliderDraggedViewTextLabel: UILabel!
    @IBOutlet weak var sliderLeftImageView: UIImageView!
    @IBOutlet weak var sliderRightImageView: UIImageView!
    
    // MARK: Delegate
    
    public weak var delegate: SSSliderDelegate?
    
    // MARK: Flags
    
    public var isTextChangeAnimating: Bool = true
    
    private var previousTranslatedPoint: CGFloat = 0
    private var constant_leadingConstraint_sliderDraggedView: CGFloat = 15
    private var constant_trailingConstraint_sliderDraggedView: CGFloat = 15
    private var sliderDraggedViewTextLabelMinimalWidth: CGFloat? // Used when slider position is 'right'
    
    public var originalSliderPosition: SSSliderPosition? {
        didSet {
            switch originalSliderPosition {
                
            case .left:
                sliderPosition = .left
                sliderLeftImageView.isHidden = false
                sliderRightImageView.isHidden = true
                sliderDraggedViewTextLabel.setAnchor(anchor: .trailing,
                                                     constant: -1)
                
                leadingConstraint_sliderDraggedViewLabel.priority = .defaultLow
                sliderDraggedViewTextLabel.setAnchor(anchor: .leading,
                                                     constant: 10,
                                                     toView: sliderLeftImageView,
                                                     toAnchor: .trailing)
                
                
            case .right:
                sliderPosition = .right
                sliderLeftImageView.isHidden = true
                sliderRightImageView.isHidden = false
                sliderDraggedViewTextLabel.setAnchor(anchor: .trailing,
                                                     constant: -1,
                                                     toView: sliderRightImageView,
                                                     toAnchor: .leading)
                sliderRightImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            case .none:
                break
            }
            setup()
        }
    }
    public var isShowSliderText: Bool = true {
        didSet {
            sliderDraggedViewTextLabel.isHidden = !isShowSliderText
        }
    }
    
    public var isEnabled: Bool = true {
        didSet {
            animationChangedEnabledBlock?(isEnabled)
        }
    }
    
    // MARK: Parameters
    
    public var sliderAnimationVelocity: Double = 0.2
    
    public var sliderCornerRadius: CGFloat = 30.0 {
        didSet {
            self.sliderView.layer.cornerRadius = sliderCornerRadius
            self.sliderView.layer.cornerRadius = sliderCornerRadius
        }
    }
    
    // MARK: Colors
    
    public var sliderBackgroundColor: UIColor = UIColor.clear {
        didSet {
            sliderBackgroundView.backgroundColor = sliderBackgroundColor
            sliderDraggedViewTextLabel.textColor = sliderBackgroundColor
        }
    }
    
    public var sliderBackgroundViewTextColor: UIColor = UIColor.clear {
        didSet {
            sliderBackgroundViewTextLabel.textColor = sliderBackgroundViewTextColor
        }
    }
    
    public var sliderDraggedViewTextColor: UIColor = UIColor.clear {
        didSet {
            sliderDraggedViewTextLabel.textColor = sliderDraggedViewTextColor
        }
    }
    
    public var sliderDraggedViewBackgroundColor: UIColor = UIColor.clear {
        didSet {
            sliderDraggedView.backgroundColor = sliderDraggedViewBackgroundColor
        }
    }
    
    public var sliderImageViewBackgroundColor: UIColor = UIColor.clear {
        didSet {
            sliderLeftImageView.backgroundColor = sliderImageViewBackgroundColor
        }
    }
    
    // MARK: Font
    
    public var sliderTextFont: UIFont = UIFont.systemFont(ofSize: 15.0) {
        didSet {
            sliderBackgroundViewTextLabel.font = sliderTextFont
            sliderDraggedViewTextLabel.font = sliderTextFont
        }
    }
    
    // MARK: Private Properties
    
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var sliderPosition: SSSliderPosition?
    
    private var xEndingPoint: CGFloat {
        get {
            guard let originalSliderPosition = originalSliderPosition else {
                return 0
            }
            switch originalSliderPosition {
                
            case .left:
                let endPoint = self.sliderView.frame.maxX - Constants.sliderEndPoint
                return endPoint
            case .right:
                let endPoint = Constants.sliderEndPoint
                return endPoint
            }
            
        }
    }
    
    private var xStartPoint: CGFloat {
        get {
            guard let originalSliderPosition = originalSliderPosition else {
                return 0
            }
            switch originalSliderPosition {
                
            case .left:
                return constant_leadingConstraint_sliderDraggedView
            case .right:
                return constant_trailingConstraint_sliderDraggedView
            }
            
        }
    }
    
    private var animationChangedEnabledBlock:((Bool) -> Void)?
    
    // MARK: - View Lifecycle
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    convenience public init(frame: CGRect, delegate: SSSliderDelegate? = nil) {
        self.init(frame: frame)
        self.delegate = delegate
        setupView()
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        Bundle.main.loadNibNamed("SSSlider", owner: self, options: nil)
        self.addSubview(sliderView)
        sliderView.frame = self.bounds
        sliderView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    func setup() {
        sliderPosition = originalSliderPosition
        constant_leadingConstraint_sliderDraggedView = leadingConstraint_sliderDraggedView.constant
        constant_trailingConstraint_sliderDraggedView = self.frame.width
        addPanGesture()
    }
    
    func viewWillLayoutSubviews() {
        let widthLbl = UILabel()
        widthLbl.text = sliderDraggedViewTextLabel.text
        widthLbl.sizeToFit()
        widthLbl.layoutSubviews()
        sliderDraggedViewTextLabelMinimalWidth = widthLbl.frame.width
    }
    
    private func addPanGesture() {
        guard let originalSliderPosition = originalSliderPosition else {
            return
        }
        switch originalSliderPosition {
            
        case .left:
            panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGestureLeft(_:)))
        case .right:
            panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGestureRight(_:)))
        }
        
        panGestureRecognizer?.minimumNumberOfTouches = 1
        if let panGestureRecognizer = panGestureRecognizer {
            sliderDraggedView.addGestureRecognizer(panGestureRecognizer)
        }
    }
    
    // MARK: - Public Methods
    
    public func resetStateWithAnimation(_ animated: Bool) {
        sliderBackgroundViewTextLabel.alpha = 0
        sliderDraggedViewTextLabel.alpha = 1
        updateThumbnail(withPosition: 0, andAnimation: true)
        updateTextLabels(withPosition: 0)
        sliderPosition = originalSliderPosition
        leadingConstraint_sliderDraggedViewLabel?.constant = 10
        layoutIfNeeded()
    }
    
    // MARK: - Private Methods
    
    private func updateThumbnail(withPosition position: CGFloat, direction: SlidingDirection? = nil, andAnimation animation: Bool = false, leadingConstraint: CGFloat = 0) {
        guard let originalSliderPosition = originalSliderPosition else {
            return
        }
        switch originalSliderPosition {
            
        case .left:
            leadingConstraint_sliderDraggedView?.constant = position
            
        case .right:
            if sliderDraggedViewTextLabel.frame.width <= (sliderDraggedViewTextLabelMinimalWidth ?? 0) + 10 {
                // Dragged label text reached the end of the slider - overflow text effect
                if direction == .left {
                    leadingConstraint_sliderDraggedViewLabel?.constant -= leadingConstraint
                }
                else if direction == .right &&  leadingConstraint_sliderDraggedViewLabel.constant <= 10 {
                    leadingConstraint_sliderDraggedViewLabel?.constant += leadingConstraint
                }
            }
            
            trailingConstraint_sliderDraggedView?.constant = position
        }
        
        setNeedsLayout()
        if animation {
            UIView.animate(withDuration: sliderAnimationVelocity) {
                self.sliderView.layoutIfNeeded()
            }
        }
    }
    
    private func updateTextLabels(withPosition position: CGFloat) {
        guard let originalSliderPosition = originalSliderPosition, isTextChangeAnimating else {
            return
        }
        let textAlpha: CGFloat
        switch originalSliderPosition {
            
        case .left:
            textAlpha = (xEndingPoint - position) / xEndingPoint
        case .right:
            textAlpha = (xStartPoint - position) / xStartPoint
        }
        
        sliderDraggedViewTextLabel.alpha = textAlpha
    }
    
    @objc private func handlePanGestureLeft(_ sender: UIPanGestureRecognizer) {
        guard isEnabled else { return }
        let translatedPoint = sender.translation(in: sliderView).x
        switch sender.state {
        case .began:
            print("Began")
        case .changed:
            if translatedPoint < previousTranslatedPoint {
                print("Changed - Left")
                guard translatedPoint > 0 else {
                    return
                }
                sliderBackgroundViewTextLabel.alpha = 0
                let reverseTranslatedPoint = xEndingPoint + translatedPoint
                if reverseTranslatedPoint <= xStartPoint {
                    updateThumbnail(withPosition: xStartPoint)
                    return
                }
                updateThumbnail(withPosition: translatedPoint)
                updateTextLabels(withPosition: translatedPoint)
            } else if translatedPoint > 0 {
                print("Changed - Right")
                guard sliderPosition == .left else {
                    if translatedPoint >= xEndingPoint {
                        updateThumbnail(withPosition: xEndingPoint)
                    }
                    return
                }
                if translatedPoint >= xEndingPoint {
                    sliderBackgroundViewTextLabel.alpha = 1
                    updateThumbnail(withPosition: xEndingPoint)
                    return
                }
                updateThumbnail(withPosition: translatedPoint)
                updateTextLabels(withPosition: translatedPoint)
            }
            
        case .ended:
            print("Ended")
            sliderBackgroundViewTextLabel.alpha = 0
            if translatedPoint > xStartPoint && translatedPoint < xEndingPoint - Constants.sliderEndPoint {
                resetStateWithAnimation(true)
            } else if translatedPoint >= xEndingPoint - Constants.sliderEndPoint {
                delegate?.sliderDidFinishSliding(self, at: .right)
                resetStateWithAnimation(true)
            }
            
        default:
            break
        }
        previousTranslatedPoint = translatedPoint
    }
    
    
    @objc private func handlePanGestureRight(_ sender: UIPanGestureRecognizer) {
        guard isEnabled else { return }
        let translatedPoint = sender.translation(in: sliderView).x
        
        switch sender.state {
            
        case .began:
            print("Began")
            
        case .changed:
            
            if translatedPoint > previousTranslatedPoint {
                print("Changed - Right")
                guard translatedPoint < 0 else {
                    return
                }
                sliderBackgroundViewTextLabel.alpha = 0
                let reverseTranslatedPoint = xStartPoint + translatedPoint
                if reverseTranslatedPoint <= xEndingPoint {
                    sliderBackgroundViewTextLabel.alpha = 1
                    updateThumbnail(withPosition: xStartPoint - reverseTranslatedPoint)
                    return
                }
                updateThumbnail(withPosition: -1 * translatedPoint, direction: .right, leadingConstraint: translatedPoint - previousTranslatedPoint)
                updateTextLabels(withPosition: -1 * translatedPoint)
            } else if translatedPoint <= 0 {
                print("Changed - Left")
                
                let reverseTranslatedPoint = xStartPoint + translatedPoint
                if reverseTranslatedPoint <= xEndingPoint {
                    sliderBackgroundViewTextLabel.alpha = 1
                    sliderDraggedViewTextLabel.alpha = 0
                    return
                }
                updateThumbnail(withPosition: -1 * translatedPoint, direction: .left, leadingConstraint: previousTranslatedPoint - translatedPoint)
                updateTextLabels(withPosition: -1 * translatedPoint)
            }
            
        case .ended:

            let reverseTranslatedPoint = xStartPoint + translatedPoint
            if reverseTranslatedPoint <= xStartPoint && reverseTranslatedPoint > xEndingPoint {
                resetStateWithAnimation(true)
            } else if reverseTranslatedPoint <= xEndingPoint {
                resetStateWithAnimation(true)
                delegate?.sliderDidFinishSliding(self, at: .left)
            }
            
        default:
            break
        }
        previousTranslatedPoint = translatedPoint
    }
}

