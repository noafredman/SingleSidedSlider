//
//  ViewController.swift
//  SSSlider
//
//  Created by Noa Fredman on 23/03/2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var slider: SSSlider!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSlider()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        slider.viewWillLayoutSubviews()
    }
    
    func setupSlider() {
        slider.delegate = self
        slider.isTextChangeAnimating = true
        slider.isEnabled = true
        slider.sliderAnimationVelocity = 0.2
        slider.sliderCornerRadius = slider.frame.height / 2
        slider.originalSliderPosition = .left
        slider.sliderView.backgroundColor = .gray
        slider.sliderDraggedViewTextLabel.text = "Slide to confirm"
        slider.sliderBackgroundViewTextLabel.text = "Release to confirm"
        
    }
}

extension ViewController: SSSliderDelegate {
    
    func sliderDidFinishSliding(_ slider: SSSlider, at position: SSSliderPosition) {
        // Do something
        print("Slider at end - Confirm!")
    }
    
}
