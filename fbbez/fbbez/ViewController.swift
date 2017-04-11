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


class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		let v = MyCustomView(frame: CGRect(x: 20, y: 20, width: 400, height: 400))
		
		v.backgroundColor = .white
		
		self.view.addSubview(v)
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

