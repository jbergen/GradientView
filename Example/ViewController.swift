//
//  ViewController.swift
//  GradientView
//
//  Created by Sam Soffes on 7/19/14.
//  Copyright (c) 2014 Sam Soffes. All rights reserved.
//

import UIKit
import GradientView

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
        let colors = [
            UIColor.yellowColor(),
            UIColor.purpleColor()
        ]

        let linearGradientView = LinearGradientView(frame: CGRect(x: 20, y: 80, width: view.bounds.width - 40, height: 150))
		linearGradientView.colors = colors
        linearGradientView.style = .Vertical
        view.addSubview(linearGradientView)
		
        let radialGradientView = RadialGradientView(frame: CGRect(x: linearGradientView.frame.origin.x, y: CGRectGetMaxY(linearGradientView.frame) + 20, width: linearGradientView.bounds.width, height: linearGradientView.bounds.height))
        radialGradientView.colors = colors
        radialGradientView.style = .Fill
        view.addSubview(radialGradientView)
	}
	
	@IBAction func showAlert(sender: UIButton) {
		let alert = UIAlertController(title: "Dimming", message: "As part of iOS 7 design language, views should become desaturated when an alert view appears.", preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "Awesome", style: .Default, handler: nil))
		presentViewController(alert, animated: true, completion: nil)
	}
}
