//
//  ViewController.swift
//  fbbez
//
//  Created by Don Mini on 4/10/17.
//  Copyright © 2017 DonMag. All rights reserved.
//

import UIKit

class MyCustomView :UIView{
	
	//Write your code in drawRect
	override func draw(_ rect: CGRect) {
		
		//		var myBezier = UIBezierPath()
		//		myBezier.moveToPoint(CGPoint(x: 0, y: 0))
		//		myBezier.addLineToPoint(CGPoint(x: 100, y: 0))
		//		myBezier.addLineToPoint(CGPoint(x: 50, y: 100))
		//		myBezier.closePath()
		
		var pth = UIBezierPath()
		
		var pt = CGPoint(x: 40, y: 10)
		
		pth.move(to: pt)
		
		pt.x += 120
		
		pth.addLine(to: pt)
		
		pt.x += 140
		pt.y += 150
		
		pth.addLine(to: pt)
		
		pt.x -= 60
		pt.y += 140
		
		pth.addLine(to: pt)
		
		pt.x -= 150
		
		pth.addLine(to: pt)
		
		pth.close()
		
		UIColor.yellow.setFill()
		UIColor.blue.setStroke()
		
		pth.lineWidth = 12
		
		//		pth.stroke()
		
		
		var sp = pth.cgPath.copy(strokingWithWidth: 10, lineCap: .square, lineJoin: .miter, miterLimit: 10)
		
		
		
		var spp = UIBezierPath(cgPath: sp)
		
		let combined = UIBezierPath()
		combined.append(pth)
		combined.append(spp)
		
		combined.close()
		
		combined.usesEvenOddFillRule = false
		
		
		var upth = spp.fb_union(pth)
		
		//var upth = pth.fb_union(spp)
		
		//		combined.fill()
		//		combined.stroke()
		
		upth.fill()
		
	}
	
	
}


class CustomView2View: UIView {
	
	var data: [CGFloat] = [10, 20, 30, 35, 50, 60, 50, 20, 30, 10] {
		didSet {
			setNeedsDisplay()
		}
	}
	
	func coordXFor(index: Int) -> CGFloat {
		return bounds.height - bounds.height * data[index] / (data.max() ?? 0)
	}
	
	override func draw(_ rect: CGRect) {
		
		let path = quadCurvedPath()
		
		path.close()
		UIColor.green.setFill()
		path.fill()
		
		UIColor.black.setStroke()
		path.lineWidth = 1
		path.stroke()
	}
	
	func quadCurvedPath() -> UIBezierPath {
		let path = UIBezierPath()
		let step = bounds.width / CGFloat(data.count - 1)
		
		var p1 = CGPoint(x: 0, y: coordXFor(index: 0))
		path.move(to: p1)
		
		drawPoint(point: p1, color: UIColor.red, radius: 3)
		
		if (data.count == 2) {
			path.addLine(to: CGPoint(x: step, y: coordXFor(index: 1)))
			return path
		}
		
		var oldControlP: CGPoint?
		
		for i in 1..<data.count {
			let p2 = CGPoint(x: step * CGFloat(i), y: coordXFor(index: i))
			drawPoint(point: p2, color: UIColor.red, radius: 3)
			var p3: CGPoint?
			if i == data.count - 1 {
				p3 = nil
			} else {
				p3 = CGPoint(x: step * CGFloat(i + 1), y: coordXFor(index: i + 1))
			}
			
			let newControlP = controlPointForPoints(p1: p1, p2: p2, p3: p3)
			
			path.addCurve(to: p2, controlPoint1: oldControlP ?? p1, controlPoint2: newControlP ?? p2)
			
			p1 = p2
			oldControlP = imaginFor(point1: newControlP, center: p2)
		}
		return path;
	}
	
	func imaginFor(point1: CGPoint?, center: CGPoint?) -> CGPoint? {
		guard let p1 = point1, let center = center else {
			return nil
		}
		let newX = 2 * center.x - p1.x
		let diffY = abs(p1.y - center.y)
		let newY = center.y + diffY * (p1.y < center.y ? 1 : -1)
		
		return CGPoint(x: newX, y: newY)
	}
	
	func midPointForPoints(p1: CGPoint, p2: CGPoint) -> CGPoint {
		return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2);
	}
	
	func controlPointForPoints(p1: CGPoint, p2: CGPoint, p3: CGPoint?) -> CGPoint? {
		guard let p3 = p3 else {
			return nil
		}
		
		let leftMidPoint  = midPointForPoints(p1: p1, p2: p2)
		let rightMidPoint = midPointForPoints(p1: p2, p2: p3)
		
		var controlPoint = midPointForPoints(p1: leftMidPoint, p2: imaginFor(point1: rightMidPoint, center: p2)!)
		
		
		// this part needs for optimization
		
		if p1.y < p2.y {
			if controlPoint.y < p1.y {
				controlPoint.y = p1.y
			}
			if controlPoint.y > p2.y {
				controlPoint.y = p2.y
			}
		} else {
			if controlPoint.y > p1.y {
				controlPoint.y = p1.y
			}
			if controlPoint.y < p2.y {
				controlPoint.y = p2.y
			}
		}
		
		let imaginContol = imaginFor(point1: controlPoint, center: p2)!
		if p2.y < p3.y {
			if imaginContol.y < p2.y {
				controlPoint.y = p2.y
			}
			if imaginContol.y > p3.y {
				let diffY = abs(p2.y - p3.y)
				controlPoint.y = p2.y + diffY * (p3.y < p2.y ? 1 : -1)
			}
		} else {
			if imaginContol.y > p2.y {
				controlPoint.y = p2.y
			}
			if imaginContol.y < p3.y {
				let diffY = abs(p2.y - p3.y)
				controlPoint.y = p2.y + diffY * (p3.y < p2.y ? 1 : -1)
			}
		}
		
		return controlPoint
	}
	
	func drawPoint(point: CGPoint, color: UIColor, radius: CGFloat) {
		let ovalPath = UIBezierPath(ovalIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2))
		color.setFill()
		ovalPath.fill()
	}
	
}

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
//		let v = MyCustomView(frame: CGRect(x: 20, y: 20, width: 300, height: 400))

		let v = CustomView2View(frame: CGRect(x: 20, y: 20, width: 300, height: 400))

		v.backgroundColor = .white
		
		self.view.addSubview(v)
		
		v.data = [1, 1, 2, 2, 3, 2.5, 4, 1.5, 5, 4, 5.5, 1, 4, -1, 2, -2]
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

