//
//  GradientView.swift
//  Gradient View
//
//  Created by Sam Soffes on 10/27/09.
//  Copyright (c) 2009-2014 Sam Soffes. All rights reserved.
//

import UIKit

public class LinearGradientView: GradientView {
    
    /// The direction of the gradient.
    public enum LinearStyle {
        /// The gradient is vertical.
        case Vertical
        
        /// The gradient is horizontal
        case Horizontal
        
        /**
        The gradient attributes determined by the user
        */
        case Custom(CGPoint, CGPoint)
        
        private func points(size: CGSize) -> (CGPoint, CGPoint) {
            switch self {
            case .Vertical:
                return (CGPointZero, CGPoint(x: 0, y: size.height))
            case .Horizontal:
                return (CGPointZero, CGPoint(x: size.width, y: 0))
            case .Custom(let start, let end):
                return (start, end)
            }
        }
    }
    
    /// The direction of the gradient. Only valid for the `Mode.Linear` mode. The default is `.Vertical`.
    public var style: LinearStyle = .Vertical {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override public func drawRect(rect: CGRect) {
        if let gradient = gradient {
            let context = UIGraphicsGetCurrentContext()
            let options: CGGradientDrawingOptions = [.DrawsAfterEndLocation]
            let (startPoint, endPoint) = style.points(bounds.size)
            
            CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, options)
        }
    }
}

public class RadialGradientView: GradientView {
    
    public enum RadialStyle {
        case Fit
        case Fill
        case Custom(CGPoint, CGFloat, CGPoint, CGFloat)
        
        private func points(size: CGSize) -> (CGPoint, CGFloat, CGPoint, CGFloat) {
            switch self {
            case .Fit:
                return (CGPoint(x: size.width / 2, y: size.height / 2), 0, CGPoint(x: size.width / 2, y: size.height / 2), min(size.width, size.height) / 2)
            case .Fill:
                return (CGPoint(x: size.width / 2, y: size.height / 2), 0, CGPoint(x: size.width / 2, y: size.height / 2), max(size.width, size.height) / 2)
            case .Custom(let startPoint, let startRadius, let endPoint, let endRadius):
                return (startPoint, startRadius, endPoint, endRadius)
            }
        }
    }
    
    public var style: RadialStyle = .Fit {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override public func drawRect(rect: CGRect) {
        if let gradient = gradient {
            let context = UIGraphicsGetCurrentContext()
            let options: CGGradientDrawingOptions = [.DrawsBeforeStartLocation, .DrawsAfterEndLocation]
            let (startPoint, startRadius, endPoint, endRadius) = style.points(bounds.size)
            
            CGContextDrawRadialGradient(context, gradient, startPoint, startRadius, endPoint, endRadius, options)
        }
    }

}


/// Simple view for drawing gradients
public class GradientView: UIView {

	// MARK: - Properties

	/// An optional array of `UIColor` objects used to draw the gradient. If the value is `nil`, the `backgroundColor`
	/// will be drawn instead of a gradient. The default is `nil`.
	public var colors: [UIColor]? {
		didSet {
			updateGradient()
		}
	}

	/// An array of `UIColor` objects used to draw the dimmed gradient. If the value is `nil`, `colors` will be
	/// converted to grayscale. This will use the same `locations` as `colors`. If length of arrays don't match, bad
	/// things will happen. You must make sure the number of dimmed colors equals the number of regular colors.
	///
	/// The default is `nil`.
	public var dimmedColors: [UIColor]? {
		didSet {
			updateGradient()
		}
	}

	/// Automatically dim gradient colors when prompted by the system (i.e. when an alert is shown).
	///
	/// The default is `true`.
	public var automaticallyDims: Bool = true

	/// An optional array of `CGFloat`s defining the location of each gradient stop.
	///
	/// The gradient stops are specified as values between `0` and `1`. The values must be monotonically increasing. If
	/// `nil`, the stops are spread uniformly across the range.
	///
	/// Defaults to `nil`.
	public var locations: [CGFloat]? {
		didSet {
			updateGradient()
		}
	}
    
	// MARK: - UIView

	override public func tintColorDidChange() {
		super.tintColorDidChange()

		if automaticallyDims {
			updateGradient()
		}
	}

	override public func didMoveToWindow() {
		super.didMoveToWindow()
		contentMode = .Redraw
	}


	// MARK: - Private

	private var gradient: CGGradientRef?

	private func updateGradient() {
		gradient = nil
		setNeedsDisplay()

		let colors = gradientColors()
		if let colors = colors {
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			let colorSpaceModel = CGColorSpaceGetModel(colorSpace)

			let gradientColors: NSArray = colors.map { (color: UIColor) -> AnyObject! in
				let cgColor = color.CGColor
				let cgColorSpace = CGColorGetColorSpace(cgColor)

				// The color's color space is RGB, simply add it.
				if CGColorSpaceGetModel(cgColorSpace).rawValue == colorSpaceModel.rawValue {
					return cgColor as AnyObject!
				}

				// Convert to RGB. There may be a more efficient way to do this.
				var red: CGFloat = 0, blue: CGFloat = 0, green: CGFloat = 0, alpha: CGFloat = 0
				color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                
				return UIColor(red: red, green: green, blue: blue, alpha: alpha).CGColor as AnyObject!
			}

			// TODO: This is ugly. Surely there is a way to make this more concise.
			if let locations = locations {
				gradient = CGGradientCreateWithColors(colorSpace, gradientColors, locations)
			} else {
				gradient = CGGradientCreateWithColors(colorSpace, gradientColors, nil)
			}
		}
	}

	private func gradientColors() -> [UIColor]? {
		if tintAdjustmentMode == .Dimmed {
			if let dimmedColors = dimmedColors {
				return dimmedColors
			}

			if automaticallyDims {
				if let colors = colors {
					return colors.map {
						var hue: CGFloat = 0,
						brightness: CGFloat = 0,
						alpha: CGFloat = 0

						$0.getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)

						return UIColor(hue: hue, saturation: 0, brightness: brightness, alpha: alpha)
					}
				}
			}
		}

		return colors
	}
}
