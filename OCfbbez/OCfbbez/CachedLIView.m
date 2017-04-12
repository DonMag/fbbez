//
//  CachedLIView.m
//  OCfbbez
//
//  Created by Don Mag on 4/11/17.
//  Copyright © 2017 DonMag. All rights reserved.
//

#import "CachedLIView.h"

#import "OCfbbez-swift.h"

@implementation CachedLIView
{
	UIBezierPath *path;
	UIImage *incrementalImage; // (1)

	UIColor *bkgColor;
	
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		bkgColor = [UIColor colorWithRed:102.0 / 255.0 green:204.0 / 255.0 blue:1.0 alpha:1.0];

		[self setMultipleTouchEnabled:NO];
		[self setBackgroundColor:bkgColor];
		path = [UIBezierPath bezierPath];
		[path setLineWidth:2.0];
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	[incrementalImage drawInRect:rect]; // (3)
	[path stroke];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint p = [touch locationInView:self];
	[path moveToPoint:p];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint p = [touch locationInView:self];
	[path addLineToPoint:p];
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event // (2)
{
	UITouch *touch = [touches anyObject];
	CGPoint p = [touch locationInView:self];
	[path addLineToPoint:p];
	
	[path closePath];
	
	[self drawBitmap]; // (3)
	[self setNeedsDisplay];
	[path removeAllPoints]; //(4)
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

- (void)drawBitmap // (3)
{
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
	
	if (!incrementalImage) // first draw; paint background by ...
	{
		UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds]; // enclosing bitmap by a rectangle defined by another UIBezierPath object
		[bkgColor setFill];
		[rectpath fill];
	}
	[incrementalImage drawAtPoint:CGPointZero];
	
	[[UIColor redColor] setFill];
	[path fill];
	
	[[UIColor blueColor] setStroke];
	[path stroke];

	CGAffineTransform move = CGAffineTransformMakeTranslation(80, 80);

	CGFloat thick = 26.0;
	CGPathRef pathOutline = CGPathCreateCopyByStrokingPath([path CGPath], NULL, thick, kCGLineCapSquare, kCGLineJoinBevel, thick);

	pathOutline = CGPathCreateCopyByStrokingPath([path CGPath], NULL, thick, kCGLineCapRound, kCGLineJoinRound, thick);
	pathOutline = CGPathCreateCopyByStrokingPath([path CGPath], NULL, thick, kCGLineCapButt, kCGLineJoinMiter, thick * 2);

	UIBezierPath *oPath = [UIBezierPath bezierPathWithCGPath:pathOutline];
	
	[[UIColor yellowColor] setFill];
	[oPath fill];
	
	UIBezierPath *uPath = [oPath fb_union:path];

	move = CGAffineTransformMakeTranslation(0, 200);

	[uPath applyTransform:move];
	
	[[UIColor greenColor] setFill];
	[uPath fill];
	
	[[UIColor purpleColor] setStroke];
	[uPath stroke];
	
	
	incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

//	[[UIColor blackColor] setStroke];
//	[path stroke];
//	incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
//	UIGraphicsEndImageContext();
}
@end

